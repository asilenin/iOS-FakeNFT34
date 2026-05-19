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
}

@Observable
@MainActor
final class CartViewModel {
    private(set) var state: CartScreenState = .idle
    private(set) var items: [CartItem] = []
    private(set) var isDeleting = false
    var error: Error?

    var sortOption: CartSortOption = .name {
        didSet {
            guard sortOption != oldValue else { return }
            applySorting()
        }
    }

    private var lastDeleteItem: CartItem?

    var totalCountText: String {
        "\(items.count) NFT"
    }

    var totalPriceText: String {
        let total = items.reduce(0) { $0 + $1.price }
        return CartPriceFormatter.eth(total)
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
}
