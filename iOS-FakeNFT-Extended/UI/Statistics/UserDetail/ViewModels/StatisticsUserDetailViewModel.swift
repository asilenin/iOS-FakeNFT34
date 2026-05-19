//
//  StatisticsUserDetailViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class StatisticsUserDetailViewModel {

    // MARK: - Dependencies

    private let statisticsService: StatisticsServiceProtocol

    // MARK: - Input

    let summary: StatisticsUser

    // MARK: - State

    private(set) var detail: StatisticsUserDetail?
    private(set) var state: StatisticsUserDetailState = .loading
    var loadError: Error?

    // MARK: - Computed Properties

    var userId: String { summary.id }

    var displayName: String { detail?.name ?? summary.name }

    var displayDescription: String { detail?.description ?? "" }

    var avatarURL: URL? { detail?.avatarURL ?? summary.avatarURL }

    var nftsCount: Int { detail?.nftsCount ?? summary.nftsCount }

    var websiteURL: URL? {
        guard let url = detail?.websiteURL else { return nil }
        return url.scheme == "https" || url.scheme == "http" ? url : nil
    }

    // MARK: - Init

    init(summary: StatisticsUser, statisticsService: StatisticsServiceProtocol) {
        self.summary = summary
        self.statisticsService = statisticsService
    }

    // MARK: - Public Methods

    func load() async {
        state = .loading
        loadError = nil

        do {
            detail = try await statisticsService.fetchUserDetail(userId: summary.id)
            state = .success
        } catch {
            detail = nil
            loadError = error
            state = .error(error)
        }
    }
}
