//
//  StatisticsNftGridCellActions.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

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
