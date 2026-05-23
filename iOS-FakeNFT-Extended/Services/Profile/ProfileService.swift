//
//  ProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 07.05.2026.
//

import Foundation

actor ProfileService: ProfileServiceProtocol {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadProfile() async throws -> Profile {
        let request = ProfileRequest()
        return try await networkClient.send(request: request)
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        try await networkClient.send(
            request: UpdateProfileRequest(profile: profile)
        )
    }
}
