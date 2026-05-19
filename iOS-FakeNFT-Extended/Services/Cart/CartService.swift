//
//  CartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 11.05.2026.
//

import Foundation

actor CartService: CartServiceProtocol {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCartItems() async throws -> [CartItem] {
        let ids = try await loadCart()

        return try await withThrowingTaskGroup(
            of: CartItem.self
        ) { group in
            for id in ids {
                group.addTask { [networkClient] in
                    let dto: CartNftDTO = try await networkClient.send(
                        request: LoadNftRequest(nftID: id)
                    )

                    return CartItem(dto: dto)
                }
            }

            var items: [CartItem] = []

            for try await item in group {
                items.append(item)
            }

            return items.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        }
    }

    func loadCart() async throws -> Set<String> {
        let order: CartOrderDTO = try await networkClient.send(
            request: LoadOrderRequest()
        )

        return Set(order.nfts)
    }

    func setCart(_ ids: Set<String>) async throws {
        _ = try await networkClient.send(
            request: UpdateOrderRequest(ids: ids)
        )
    }
}
