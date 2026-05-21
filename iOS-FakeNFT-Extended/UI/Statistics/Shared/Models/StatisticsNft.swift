//
//  StatisticsNft.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import Foundation

struct StatisticsNft: Sendable, Identifiable, Hashable, Equatable {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let price: Float
}
