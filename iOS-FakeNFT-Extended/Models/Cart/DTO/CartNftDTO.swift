//
//  NFTDTO.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 09.05.2026.
//

import Foundation

struct CartNftDTO: Decodable, Sendable {
    let id: String
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Double
    let author: String
    let website: String
    let createdAt: String
}
