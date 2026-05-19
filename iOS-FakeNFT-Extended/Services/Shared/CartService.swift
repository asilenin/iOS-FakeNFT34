//
//  CartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

actor CartService: CartServiceProtocol {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCart() async throws -> Set<String> {
        let order: OrderNetworkDTO = try await networkClient.send(request: GetOrderRequest())
        return NetworkIdListParser.parseSet(order.nfts)
    }

    func setCart(_ ids: Set<String>) async throws {
        _ = try await networkClient.send(request: UpdateOrderRequest(nftIds: ids))
    }
}
