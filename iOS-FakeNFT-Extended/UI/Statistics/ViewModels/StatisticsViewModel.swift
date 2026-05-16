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

    // MARK: - Dependencies

    private let statisticsService: StatisticsServiceProtocol
    private let sortSettings: StatisticsSortSettingsStorage

    // MARK: - State

    private(set) var users: [StatisticsUser] = []
    private(set) var state: StatisticsState = .loading
    var sortOption: StatisticsSortOption

    // MARK: - Init

    init(
        statisticsService: StatisticsServiceProtocol,
        sortSettings: StatisticsSortSettingsStorage = UserDefaultsStatisticsSortSettings()
    ) {
        self.statisticsService = statisticsService
        self.sortSettings = sortSettings
        self.sortOption = sortSettings.load()
    }

    // MARK: - Public Methods

    func load() async {
        state = .loading
        do {
            let fetched = try await statisticsService.fetchRankingUsers()
            users = fetched
            applySort()
            state = users.isEmpty ? .empty : .success
        } catch {
            users = []
            state = .error(error)
        }
    }

    func setSortOption(_ option: StatisticsSortOption) {
        sortOption = option
        sortSettings.save(option)
        if case .success = state { applySort() }
    }

    // MARK: - Private Methods

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
