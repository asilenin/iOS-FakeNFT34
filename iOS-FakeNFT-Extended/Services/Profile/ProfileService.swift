//
//  ProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 07.05.2026.
//

import Foundation

actor ProfileService: ProfileServiceProtocol {
    private let networkClient: NetworkClient
    private var cachedProfile: Profile?

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadProfile() async throws -> Profile {
        if let cachedProfile {
            return cachedProfile
        }
        let profile: Profile = try await networkClient.send(request: ProfileRequest())
        cachedProfile = profile
        return profile
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        let updated: Profile = try await networkClient.send(
            request: UpdateProfileRequest(profile: profile)
        )
        cachedProfile = updated
        return updated
    }

    func invalidateCache() async {
        cachedProfile = nil
    }
}
