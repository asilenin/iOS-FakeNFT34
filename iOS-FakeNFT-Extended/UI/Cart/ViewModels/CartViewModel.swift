//
//  CartViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 11.05.2026.
//

import Foundation
import Observation

enum CartSortOption: String, CaseIterable, Identifiable, Sendable {
    case name
    case price
    case rating

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name: "По названию"
        case .price: "По цене"
        case .rating: "По рейтингу"
        }
    }
}

@Observable
@MainActor
final class CartViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error
    }

    private enum Constants {
        static let sortStorageKey = "cart.sort.option"
    }

    private(set) var state: State = .idle
    private(set) var items: [CartItem] = []
    private(set) var isDeleting = false
    var error: Error?

    var sortOption: CartSortOption {
        didSet {
            UserDefaults.standard.set(sortOption.rawValue, forKey: Constants.sortStorageKey)
            applySorting()
        }
    }

    private var lastDeleteItem: CartItem?

    init() {
        let savedSort = UserDefaults.standard.string(forKey: Constants.sortStorageKey)
        sortOption = savedSort.flatMap(CartSortOption.init(rawValue:)) ?? .name
    }

    var totalCountText: String {
        "\(items.count) NFT"
    }

    var totalPriceText: String {
        let total = items.reduce(0) { $0 + $1.price }

        return String(format: "%.2f ETH", total)
            .replacingOccurrences(of: ".", with: ",")
    }

    func loadIfNeeded(service: CartServiceProtocol) async {
        guard state == .idle else { return }
        await load(service: service)
    }

    func load(service: CartServiceProtocol) async {
        state = .loading
        error = nil
        lastDeleteItem = nil

        do {
            items = try await service.loadCartItems()
            applySorting()
            state = items.isEmpty ? .empty : .loaded
        } catch {
            items = []
            self.error = error
            state = .error
        }
    }

    func delete(_ item: CartItem, service: CartServiceProtocol) async {
        guard !isDeleting else { return }

        let previousItems = items
        let updatedIDs = Set(items.map(\.id)).subtracting([item.id])

        isDeleting = true
        error = nil
        lastDeleteItem = item
        items.removeAll { $0.id == item.id }
        state = items.isEmpty ? .empty : .loaded

        do {
            try await service.setCart(updatedIDs)
            lastDeleteItem = nil
        } catch {
            items = previousItems
            applySorting()
            state = items.isEmpty ? .empty : .loaded
            self.error = error
        }

        isDeleting = false
    }

    func retryLastDelete(service: CartServiceProtocol) async {
        guard let lastDeleteItem else {
            await load(service: service)
            return
        }

        await delete(lastDeleteItem, service: service)
    }

    private func applySorting() {
        switch sortOption {
        case .name:
            items.sort {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .price:
            items.sort { $0.price < $1.price }
        case .rating:
            items.sort { $0.rating > $1.rating }
        }
    }

#if DEBUG
    func loadMock() {
        items = [
            CartItem(
                id: "1",
                title: "April",
                imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки/April_1.png"),
                rating: 1,
                price: 1.78
            ),
            CartItem(
                id: "2",
                title: "Greena",
                imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки/Greena_1.png"),
                rating: 3,
                price: 1.78
            ),
            CartItem(
                id: "3",
                title: "Spring",
                imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки/Spring_1.png"),
                rating: 5,
                price: 1.78
            )
        ]

        applySorting()
        state = .loaded
    }

    static func previewLoaded() -> CartViewModel {
        let viewModel = CartViewModel()
        viewModel.loadMock()
        return viewModel
    }

    static func previewEmpty() -> CartViewModel {
        let viewModel = CartViewModel()
        viewModel.items = []
        viewModel.state = .empty
        return viewModel
    }

    static func previewLoading() -> CartViewModel {
        let viewModel = CartViewModel()
        viewModel.state = .loading
        return viewModel
    }

    static func previewError() -> CartViewModel {
        let viewModel = CartViewModel()
        viewModel.items = []
        viewModel.state = .error
        return viewModel
    }
#endif
}
