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
    private let favoritesService: FavoritesServiceProtocol
    private let cartService: CartServiceProtocol

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
        statisticsService: StatisticsServiceProtocol,
        favoritesService: FavoritesServiceProtocol,
        cartService: CartServiceProtocol
    ) {
        self.userId = userId
        self.userName = userName
        self.statisticsService = statisticsService
        self.favoritesService = favoritesService
        self.cartService = cartService
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

        let task = Task {
            await performLoad()
        }
        currentTask = task
        await task.value
    }

    func didTapFavorite(_ nftId: String) {
        let snapshot = favoriteIds
        toggleFavorite(nftId)

        Task {
            do {
                try await favoritesService.setFavorites(favoriteIds)
            } catch {
                favoriteIds = snapshot
                loadError = error
            }
        }
    }

    func didTapCart(_ nftId: String) {
        let snapshot = cartIds
        toggleCart(nftId)

        Task {
            do {
                try await cartService.setCart(cartIds)
            } catch {
                cartIds = snapshot
                loadError = error
            }
        }
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

    private func performLoad() async {
        state = .loading
        loadError = nil

        do {
            async let nftsTask = statisticsService.fetchUserNfts(userId: userId)
            async let favoritesTask = favoritesService.loadFavorites()
            async let cartTask = cartService.loadCart()

            let (loadedNfts, favorites, cart) = try await (nftsTask, favoritesTask, cartTask)
            try Task.checkCancellation()

            nfts = loadedNfts
            favoriteIds = favorites
            cartIds = cart
            state = loadedNfts.isEmpty ? .empty : .success
        } catch is CancellationError {
            return
        } catch {
            nfts = []
            favoriteIds = []
            cartIds = []
            loadError = error
            state = .error
        }
    }
}
