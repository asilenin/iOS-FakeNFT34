//
//  MockCartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 16.05.2026.
//

import Foundation

actor MockCartService: CartServiceProtocol {
    private var items: [CartItem]

    init() {
        let savedIDs = Self.loadSavedIDs()

        if let savedIDs {
            items = Self.mockItems.filter { savedIDs.contains($0.id) }
        } else {
            items = Self.mockItems
        }
    }

    func loadCart() async throws -> Set<String> {
        Set(items.map(\.id))
    }

    func loadCartItems() async throws -> [CartItem] {
        try await Task.sleep(for: .milliseconds(Constants.delay))
        return items
    }

    func setCart(_ ids: Set<String>) async throws -> Set<String> {
        try await Task.sleep(for: .milliseconds(Constants.delay))

        items = Self.mockItems.filter { ids.contains($0.id) }
        Self.saveIDs(ids)
        return Set(items.map(\.id))
    }

    func invalidateCache() async {}
    
    func performOrder(_ ids: Set<String>) async throws {}
}

// MARK: - Storage

private extension MockCartService {
    static func loadSavedIDs() -> Set<String>? {
        guard let ids = UserDefaults.standard.array(
            forKey: Constants.storageKey
        ) as? [String] else {
            return nil
        }

        return Set(ids)
    }

    static func saveIDs(_ ids: Set<String>) {
        UserDefaults.standard.set(
            Array(ids),
            forKey: Constants.storageKey
        )
    }
}

// MARK: - Mock data

private extension MockCartService {
    enum Constants {
        static let delay = 500
        static let storageKey = "cart.mock.ids"
    }

    static let mockItems: [CartItem] = [
        CartItem(
            id: "a06d0075-d1a7-40dc-b710-db6808c28cca",
            title: "ei hac",
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Peach/Biscuit/1.png"),
            rating: 1,
            price: 21.63
        ),
        CartItem(
            id: "b3907b86-37c4-4e15-95bc-7f8147a9a660",
            title: "voluptatum ius",
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/White/Lumpy/1.png"),
            rating: 4,
            price: 49.77
        ),
        CartItem(
            id: "cc74e9ab-2189-465f-a1a6-8405e07e9fe4",
            title: "meliore theophrastus tractatos",
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Blue/Clover/1.png"),
            rating: 2,
            price: 11.14
        )
    ]
}
