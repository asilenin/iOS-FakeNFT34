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

    var loadedProfile: Profile? {
        if case .loaded(let profile) = state {
            return profile
        }
        return nil
    }

    // MARK: - Dependencies

    private let profileService: ProfileServiceProtocol

    // MARK: - Initializers

    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }

    // MARK: - Public Methods

    func loadProfile() async {
        guard !state.isLoading else { return }

        state = .loading

        do {
            let profile = try await profileService.loadProfile()
            state = .loaded(profile)
        } catch {
            let message = String(
                format: String(localized: "Profile.error.load"),
                error.localizedDescription
            )
            state = .failed(message)
        }
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
