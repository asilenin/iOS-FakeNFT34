//
//  StatisticsUserDetail.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import Foundation

struct StatisticsUserDetail: Sendable, Hashable, Identifiable {
    let id: String
    let name: String
    let description: String
    let avatarURL: URL?
    let websiteURL: URL?
    let nftsCount: Int
    let rating: Int
}

extension StatisticsUserDetail {

    init(summary: StatisticsUser, description: String, websiteURL: URL?) {
        self.init(
            id: summary.id,
            name: summary.name,
            description: description,
            avatarURL: summary.avatarURL,
            websiteURL: websiteURL,
            nftsCount: summary.nftsCount,
            rating: summary.rating
        )
    }
}
