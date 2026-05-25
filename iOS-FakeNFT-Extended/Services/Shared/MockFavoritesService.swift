//
//  MockFavoritesService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 24.05.2026.
//

import Foundation

/// Мок для Preview и тестов.
actor MockFavoritesService: FavoritesServiceProtocol {

    private var favorites: Set<String>

    init(initialFavorites: Set<String> = []) {
        self.favorites = initialFavorites
    }

    func loadFavorites() async throws -> Set<String> {
        try await Task.sleep(for: .milliseconds(200))
        return favorites
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        try await Task.sleep(for: .milliseconds(200))
        favorites = ids
        return favorites
    }

    func invalidateCache() async {}
}
