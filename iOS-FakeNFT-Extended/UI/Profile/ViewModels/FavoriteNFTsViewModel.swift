//
//  FavoriteNFTsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 19.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class FavoriteNFTsViewModel {

    // MARK: - State

    enum State {
        case idle
        case loading
        case loaded([ProfileNft])
        case empty
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var currentProfile: Profile
    private(set) var pendingRemovalIds: Set<String> = []
    private var failedRemovalNFT: ProfileNft?
    var removalErrorMessage: String?

    // MARK: - Dependencies

    private let nftService: NftServiceProtocol
    private let profileService: ProfileServiceProtocol

    // MARK: - Initializers

    init(
        profile: Profile,
        nftService: NftServiceProtocol,
        profileService: ProfileServiceProtocol
    ) {
        currentProfile = profile
        self.nftService = nftService
        self.profileService = profileService
    }

    // MARK: - Public Methods

    func loadNFTs() async {
        guard !state.isLoading else { return }

        let likes = currentProfile.likes ?? []
        guard !likes.isEmpty else {
            state = .empty
            return
        }

        state = .loading
        removalErrorMessage = nil

        do {
            let nfts = try await withThrowingTaskGroup(of: ProfileNft.self) { group in
                for nftId in likes {
                    group.addTask { [nftService] in
                        try await nftService.loadNft(id: nftId)
                    }
                }

                var loadedNFTs: [ProfileNft] = []
                for try await nft in group {
                    loadedNFTs.append(nft)
                }

                return loadedNFTs
            }

            state = nfts.isEmpty ? .empty : .loaded(nfts)
        } catch {
            state = .failed(
                String(
                    format: String(localized: "Profile.FavoriteNFTs.error.load"),
                    error.localizedDescription
                )
            )
        }
    }

    func removeFromFavorites(_ nft: ProfileNft) async -> Profile? {
        guard let nftId = nft.id,
              !pendingRemovalIds.contains(nftId) else {
            return nil
        }

        let previousProfile = currentProfile
        let previousState = state
        let updatedLikes = (currentProfile.likes ?? []).filter { $0 != nftId }
        let updatedProfile = currentProfile.updatingLikes(updatedLikes)

        pendingRemovalIds.insert(nftId)
        removalErrorMessage = nil
        currentProfile = updatedProfile
        removeNFTFromState(id: nftId)

        do {
            let savedProfile = try await profileService.updateProfile(updatedProfile)
            currentProfile = savedProfile.updatingLikes(updatedLikes)
            pendingRemovalIds.remove(nftId)
            failedRemovalNFT = nil
            return currentProfile
        } catch {
            currentProfile = previousProfile
            state = previousState
            pendingRemovalIds.remove(nftId)
            failedRemovalNFT = nft
            removalErrorMessage = String(
                format: String(localized: "Profile.FavoriteNFTs.error.remove"),
                error.localizedDescription
            )
            return nil
        }
    }

    func retryFailedRemoval() async -> Profile? {
        guard let failedRemovalNFT else { return nil }
        return await removeFromFavorites(failedRemovalNFT)
    }

    func dismissRemovalError() {
        removalErrorMessage = nil
    }

    // MARK: - Private Methods

    private func removeNFTFromState(id: String) {
        guard case .loaded(let nfts) = state else {
            state = (currentProfile.likes ?? []).isEmpty ? .empty : state
            return
        }

        let updatedNFTs = nfts.filter { $0.id != id }
        state = updatedNFTs.isEmpty ? .empty : .loaded(updatedNFTs)
    }
}

// MARK: - FavoriteNFTsViewModel.State

private extension FavoriteNFTsViewModel.State {
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

// MARK: - Profile

private extension Profile {
    func updatingLikes(_ likes: [String]) -> Profile {
        Profile(
            id: id,
            name: name,
            description: description,
            website: website,
            avatar: avatar,
            nfts: nfts ?? [],
            likes: likes
        )
    }
}
