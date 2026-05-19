//
//  NftService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Foundation

actor NftService: NftServiceProtocol {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadNft(id: String) async throws -> ProfileNft {
        let request = NftRequest(id: id)
        return try await networkClient.send(request: request)
    }
}
