//
//  ProfileNft.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Foundation

struct ProfileNft: Codable, Hashable, Identifiable, Sendable {
    let id: String?
    let name: String?
    let images: [String]?
    let rating: Int?
    let author: String?
    let price: Double?
}
