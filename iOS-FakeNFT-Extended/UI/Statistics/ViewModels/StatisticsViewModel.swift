//
//  StatisticsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class StatisticsViewModel {

    private let statisticsService: any StatisticsServiceProtocol

    private(set) var users: [StatisticsUser] = []
    private(set) var isLoading = false
    var loadError: Error?

    var sortOption: StatisticsSortOption {
        didSet {
            UserDefaults.standard.set(sortOption.rawValue, forKey: StatisticsSortOption.appStorageKey)
            applySort()
        }
    }

    init(statisticsService: any StatisticsServiceProtocol) {
        self.statisticsService = statisticsService
        if let raw = UserDefaults.standard.string(forKey: StatisticsSortOption.appStorageKey),
           let saved = StatisticsSortOption(rawValue: raw) {
            self.sortOption = saved
        } else {
            self.sortOption = .default
        }
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        do {
            let fetched = try await statisticsService.fetchRankingUsers()
            users = fetched
            applySort()
        } catch {
            users = []
            loadError = error
        }
        isLoading = false
    }

    func setSortOption(_ option: StatisticsSortOption) {
        sortOption = option
    }

    private func applySort() {
        switch sortOption {
        case .byRating:
            users.sort { $0.rating > $1.rating }
        case .byName:
            users.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .byNftsCount:
            users.sort { $0.nftsCount > $1.nftsCount }
        }
    }
}
