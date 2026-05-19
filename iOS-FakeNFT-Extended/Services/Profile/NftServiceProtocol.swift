//
//  NftServiceProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Foundation

protocol NftServiceProtocol: Sendable {
    func loadNft(id: String) async throws -> ProfileNft
}
