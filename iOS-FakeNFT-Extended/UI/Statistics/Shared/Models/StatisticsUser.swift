//
//  StatisticsUser.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import Foundation

struct StatisticsUser: Sendable, Hashable, Identifiable {
    let id: String
    let name: String
    let avatarURL: URL?
    let nftsCount: Int
    let rating: Int
}
