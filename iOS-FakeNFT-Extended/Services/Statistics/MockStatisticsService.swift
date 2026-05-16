//
//  MockStatisticsService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import Foundation

enum MockStatisticsServiceError: Error, LocalizedError {
    case simulatedFailure

    var errorDescription: String? {
        switch self {
        case .simulatedFailure:
            return NSLocalizedString("Error.network", comment: "")
        }
    }
}

actor MockStatisticsService: StatisticsServiceProtocol {

    var shouldFailNextFetch = false
    var simulatedDelayNanoseconds: UInt64 = 350_000_000

    func fetchRankingUsers() async throws -> [StatisticsUser] {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }
        if shouldFailNextFetch {
            shouldFailNextFetch = false
            throw MockStatisticsServiceError.simulatedFailure
        }
        return Self.mockUsers
    }

    private static let mockUsers: [StatisticsUser] = [
        StatisticsUser(
            id: "1",
            name: "Alice",
            avatarURL: URL(string: "https://disk.yandex.ru/i/ZEJiBtCDi3hjYw"),
            nftsCount: 42,
            rating: 98
        ),
        StatisticsUser(
            id: "2",
            name: "Bob",
            avatarURL: URL(string: "https://disk.yandex.ru/i/QtevnFWydhy77w"),
            nftsCount: 17,
            rating: 72
        ),
        StatisticsUser(
            id: "3",
            name: "Clara",
            avatarURL: URL(string: "https://disk.yandex.ru/i/5pD61GCWkUWrpQ"),
            nftsCount: 105,
            rating: 100
        ),
        StatisticsUser(
            id: "4",
            name: "Dan",
            avatarURL: URL(string: "https://disk.yandex.ru/i/Fn9dXaBh3IPoJQ"),
            nftsCount: 3,
            rating: 40
        ),
        StatisticsUser(
            id: "5",
            name: "Eve",
            avatarURL: URL(string: "https://disk.yandex.ru/i/A2IQmYns3uj9Lw"),
            nftsCount: 64,
            rating: 88
        )
    ]
}
