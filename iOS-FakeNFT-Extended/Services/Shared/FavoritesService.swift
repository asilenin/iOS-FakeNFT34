//
//  FavoritesService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

/// Общий сервис лайков для каталога, статистики и других табов.
/// Делегирует хранение в `ProfileService` — единый источник правды для likes.
actor FavoritesService: FavoritesServiceProtocol {

    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }

    func loadFavorites() async throws -> Set<String> {
        let profile = try await profileService.loadProfile()
        return Set(profile.likes ?? [])
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        let current = try await profileService.loadProfile()
        let updated = current.updatingLikes(Array(ids))
        let saved = try await profileService.updateProfile(updated)
        return Set(saved.likes ?? [])
    }

    func invalidateCache() async {
        await profileService.invalidateCache()
    }
}
