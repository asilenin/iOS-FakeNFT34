//
//  StatisticsSortSettingsStorage.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 16.05.2026.
//

import Foundation

protocol StatisticsSortSettingsStorage: Sendable {
    func load() -> StatisticsSortOption
    func save(_ option: StatisticsSortOption)
}

struct UserDefaultsStatisticsSortSettings: StatisticsSortSettingsStorage {
    func load() -> StatisticsSortOption {
        guard let raw = UserDefaults.standard.string(forKey: StatisticsSortOption.appStorageKey),
              let saved = StatisticsSortOption(rawValue: raw) else {
            return .default
        }
        return saved
    }

    func save(_ option: StatisticsSortOption) {
        UserDefaults.standard.set(option.rawValue, forKey: StatisticsSortOption.appStorageKey)
    }
}
