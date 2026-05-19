//
//  FavoritesService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

actor FavoritesService: FavoritesServiceProtocol {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadFavorites() async throws -> Set<String> {
        let profile: ProfileNetworkDTO = try await networkClient.send(request: GetProfileRequest())
        return NetworkIdListParser.parseSet(profile.likes)
    }

    func setFavorites(_ ids: Set<String>) async throws {
        _ = try await networkClient.send(request: UpdateProfileLikesRequest(likes: ids))
    }
}
