//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 07.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    // MARK: - State

    enum State {
        case idle
        case loading
        case loaded(Profile)
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var purchasedNFTIds: Set<String> = []

    var loadedProfile: Profile? {
        if case .loaded(let profile) = state {
            return profile
        }
        return nil
    }

    var myNFTsCount: Int {
        let profileIds = Set(loadedProfile?.nfts ?? [])
        return profileIds.union(purchasedNFTIds).count
    }

    // MARK: - Dependencies

    private let profileService: ProfileServiceProtocol
    private let purchasedNFTsStorage: PurchasedNFTsStorageProtocol

    // MARK: - Initializers

    init(
        profileService: ProfileServiceProtocol,
        purchasedNFTsStorage: PurchasedNFTsStorageProtocol
    ) {
        self.profileService = profileService
        self.purchasedNFTsStorage = purchasedNFTsStorage
    }

    // MARK: - Public Methods

    func loadProfile() async {
        guard !state.isLoading else { return }

        state = .loading

        do {
            async let profile = profileService.loadProfile()
            async let purchasedIds = purchasedNFTsStorage.loadPurchasedNFTIds()

            let loadedProfile = try await profile
            purchasedNFTIds = await purchasedIds

            state = .loaded(loadedProfile)
        } catch {
            let message = String(
                format: String(localized: "Profile.error.load"),
                error.localizedDescription
            )
            state = .failed(message)
        }
    }

    func myNFTIds() async -> [String] {
        let profileIds = Set(loadedProfile?.nfts ?? [])
        let purchasedIds = await purchasedNFTsStorage.loadPurchasedNFTIds()

        purchasedNFTIds = purchasedIds

        return Array(profileIds.union(purchasedIds))
    }

    func updateLoadedProfile(_ profile: Profile) {
        state = .loaded(profile)
    }

    func updateFavoriteIds(_ favoriteIds: [String]) async throws -> Profile {
        guard let profile = loadedProfile else {
            throw URLError(.badServerResponse)
        }

        let updatedProfile = profile.updatingLikes(favoriteIds)
        let savedProfile = try await profileService.updateProfile(updatedProfile)
        let actualProfile = savedProfile.updatingLikes(favoriteIds)
        state = .loaded(actualProfile)

        return actualProfile
    }
}

// MARK: - ProfileViewModel.State

private extension ProfileViewModel.State {
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
