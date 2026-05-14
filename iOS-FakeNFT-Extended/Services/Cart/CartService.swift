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
        // Sprint 3 adds PUT /api/v1/orders/1 with form-urlencoded body.
        _ = ids
        throw CartServiceError.updateOrderNotImplemented
    }
}

enum CartServiceError: LocalizedError {
    case updateOrderNotImplemented

    var errorDescription: String? {
        switch self {
        case .updateOrderNotImplemented:
            "Обновление корзины будет реализовано в Sprint 3."
        }
    }
}
