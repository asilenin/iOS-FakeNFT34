//
//  CartViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 11.05.2026.
//

import Foundation
import Observation

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

    private(set) var state: State = .idle
    private(set) var items: [CartItem] = []
    var error: Error?

    var totalCountText: String {
        "\(items.count) NFT"
    }

    var totalPriceText: String {
        let total = items.reduce(0) { $0 + $1.price }
        return String(format: "%.2f ETH", total)
    }

    func loadIfNeeded(service: CartServiceProtocol) async {
        guard state == .idle else { return }
        await load(service: service)
    }

    func load(service: CartServiceProtocol) async {
        state = .loading
        error = nil

        do {
            let loadedItems = try await service.loadCartItems()

            items = loadedItems
            state = loadedItems.isEmpty ? .empty : .loaded
        } catch {
            items = []
            self.error = error
            state = .error
        }
    }

#if DEBUG
    func loadMock() {
        items = [
            CartItem(
                id: "1",
                title: "April",
                imageURL: nil,
                rating: 4,
                price: 1.78
            ),
            CartItem(
                id: "2",
                title: "Wave",
                imageURL: nil,
                rating: 5,
                price: 2.14
            ),
            CartItem(
                id: "3",
                title: "Future",
                imageURL: nil,
                rating: 3,
                price: 0.92
            )
        ]

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
