//
//  StatisticsNftGridCellConfiguration.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import Foundation

struct StatisticsNftGridCellConfiguration: Sendable, Equatable {
    let nft: StatisticsNft
    let isFavorite: Bool
    let isInCart: Bool
}

struct StatisticsNftGridCellActions {
    let onFavoriteTap: () -> Void
    let onCartTap: () -> Void
    let onCellTap: () -> Void
    
    static let preview = StatisticsNftGridCellActions(
        onFavoriteTap: {},
        onCartTap: {},
        onCellTap: {}
    )
}
