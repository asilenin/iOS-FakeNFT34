//
//  StatisticsUserCollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class StatisticsUserCollectionViewModel {

    // MARK: - Dependencies

    private let statisticsService: StatisticsServiceProtocol

    // MARK: - Input

    let userId: String
    let userName: String

    // MARK: - State

    private(set) var nfts: [StatisticsNft] = []
    private(set) var state: StatisticsUserCollectionState = .loading
    var loadError: Error?

    private(set) var favoriteIds: Set<String> = []
    private(set) var cartIds: Set<String> = []

    private var currentTask: Task<Void, Never>?

    // MARK: - Init

    init(
        userId: String,
        userName: String,
        statisticsService: StatisticsServiceProtocol
    ) {
        self.userId = userId
        self.userName = userName
        self.statisticsService = statisticsService
    }

    // MARK: - Queries

    func isFavorite(_ nftId: String) -> Bool {
        favoriteIds.contains(nftId)
    }

    func isInCart(_ nftId: String) -> Bool {
        cartIds.contains(nftId)
    }

    // MARK: - Public Methods

    func load() async {
        currentTask?.cancel()

        let task = Task { [statisticsService, userId] in
            await performLoad(using: statisticsService, userId: userId)
        }
        currentTask = task
        await task.value
    }

    func didTapFavorite(_ nftId: String) {
        toggleFavorite(nftId)
    }

    func didTapCart(_ nftId: String) {
        toggleCart(nftId)
    }

    // MARK: - Private Methods

    private func toggleFavorite(_ nftId: String) {
        if favoriteIds.contains(nftId) {
            favoriteIds.remove(nftId)
        } else {
            favoriteIds.insert(nftId)
        }
    }

    private func toggleCart(_ nftId: String) {
        if cartIds.contains(nftId) {
            cartIds.remove(nftId)
        } else {
            cartIds.insert(nftId)
        }
    }

    private func performLoad(
        using service: StatisticsServiceProtocol,
        userId: String
    ) async {
        state = .loading
        loadError = nil

        do {
            let loaded = try await service.fetchUserNfts(userId: userId)
            try Task.checkCancellation()

            nfts = loaded
            state = loaded.isEmpty ? .empty : .success
        } catch is CancellationError {
            return
        } catch {
            nfts = []
            loadError = error
            state = .error
        }
    }
}
