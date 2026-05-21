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
        let profile: CatalogProfileDto = try await networkClient.send(request: ProfileGetRequest())
        return Set(profile.likes)
    }
    
    func setFavorites(_ ids: Set<String>) async throws {
        let request = ProfileSetLikesRequest(likes: Array(ids.sorted()))
        let profile: CatalogProfileDto = try await networkClient.send(request: request)
        _ = profile
    }
}
