//
//  CartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 11.05.2026.
//

import Foundation

/// Общий сервис корзины: GET/PUT заказа через `CatalogNetworkClient` и загрузка NFT lkz экрана корзины — через `DefaultNetworkClient`.
actor CartService: CartServiceProtocol {

    private let networkClient: NetworkClient
    private let catalogNetworkClient: NetworkClient
    private var cachedIds: Set<String>?

    init(networkClient: NetworkClient, catalogNetworkClient: NetworkClient) {
        self.networkClient = networkClient
        self.catalogNetworkClient = catalogNetworkClient
    }

    func loadCart() async throws -> Set<String> {
        if let cachedIds {
            return cachedIds
        }

        let order: CatalogOrderDto = try await catalogNetworkClient.send(request: OrderGetRequest())
        let ids = Set(order.nfts)
        cachedIds = ids
        return ids
    }
    
    @discardableResult
    func setCart(_ ids: Set<String>) async throws -> Set<String> {
        let request = OrderSetNftsRequest(nfts: Array(ids))
        let order: CatalogOrderDto = try await catalogNetworkClient.send(request: request)
        let updated = Set(order.nfts)
        cachedIds = updated
        return updated
    }

    func invalidateCache() async {
        cachedIds = nil
    }

    func loadCartItems() async throws -> [CartItem] {
        let ids = try await loadCart()

        return try await withThrowingTaskGroup(of: CartItem.self) { group in
            for id in ids {
                group.addTask { [networkClient] in
                    let dto: CartNftDTO = try await networkClient.send(
                        request: NftRequest(id: id)
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
    
    func performOrder(_ ids: Set<String>) async throws {
        let request = OrderPaymentRequest(nfts: Array(ids))
        _ = try await catalogNetworkClient.send(request: request) as CatalogOrderDto
    }
}
