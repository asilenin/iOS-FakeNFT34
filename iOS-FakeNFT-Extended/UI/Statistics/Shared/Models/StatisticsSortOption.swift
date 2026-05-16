//
//  StatisticsSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import Foundation

enum StatisticsSortOption: String, CaseIterable, Identifiable, Sendable {
    case byRating
    case byName
    case byNftsCount

    var id: String { rawValue }

    static let appStorageKey = "statisticsSortOption"

    static var `default`: StatisticsSortOption { .byRating }

    var localizedTitle: String {
        switch self {
        case .byRating: return NSLocalizedString("Statistics.sort.byRating", comment: "")
        case .byName: return NSLocalizedString("Statistics.sort.byName", comment: "")
        case .byNftsCount: return NSLocalizedString("Statistics.sort.byNftsCount", comment: "")
        }
    }
}
