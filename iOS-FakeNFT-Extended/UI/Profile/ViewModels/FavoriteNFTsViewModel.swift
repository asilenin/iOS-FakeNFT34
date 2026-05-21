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
    private(set) var favoriteIds: [String]
    private(set) var pendingRemovalIds: Set<String> = []
    private var failedRemovalNFT: ProfileNft?
    var removalErrorMessage: String?

    // MARK: - Dependencies

    private let nftService: NftServiceProtocol
    private let updateFavoriteIds: ([String]) async throws -> Profile

    // MARK: - Initializers

    init(
        favoriteIds: [String],
        nftService: NftServiceProtocol,
        updateFavoriteIds: @escaping ([String]) async throws -> Profile
    ) {
        self.favoriteIds = favoriteIds
        self.nftService = nftService
        self.updateFavoriteIds = updateFavoriteIds
    }

    // MARK: - Public Methods

    func loadNFTs() async {
        guard !state.isLoading else { return }

        guard !favoriteIds.isEmpty else {
            state = .empty
            return
        }

        state = .loading
        removalErrorMessage = nil

        do {
            let nfts = try await withThrowingTaskGroup(of: ProfileNft.self) { group in
                for nftId in favoriteIds {
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

        let previousFavoriteIds = favoriteIds
        let previousState = state
        let updatedFavoriteIds = favoriteIds.filter { $0 != nftId }

        pendingRemovalIds.insert(nftId)
        removalErrorMessage = nil
        favoriteIds = updatedFavoriteIds
        removeNFTFromState(id: nftId)

        do {
            let savedProfile = try await updateFavoriteIds(updatedFavoriteIds)
            favoriteIds = savedProfile.likes ?? updatedFavoriteIds
            pendingRemovalIds.remove(nftId)
            failedRemovalNFT = nil
            return savedProfile
        } catch {
            favoriteIds = previousFavoriteIds
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
            state = favoriteIds.isEmpty ? .empty : state
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
