//
//  FavoritesService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

/// Общий сервис лайков для каталога, статистики и других табов.
actor FavoritesService: FavoritesServiceProtocol {

    private let networkClient: NetworkClient
    private var cached: Set<String>?

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadFavorites() async throws -> Set<String> {
        if let cached {
            return cached
        }

        let profile: CatalogProfileDto = try await networkClient.send(request: ProfileRequest())
        let favorites = Set(profile.likes)
        cached = favorites
        return favorites
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        let request = ProfileSetLikesRequest(likes: Array(ids))
        let profile: CatalogProfileDto = try await networkClient.send(request: request)
        let updated = Set(profile.likes)
        cached = updated
        return updated
    }

    func invalidateCache() async {
        cached = nil
    }
}
