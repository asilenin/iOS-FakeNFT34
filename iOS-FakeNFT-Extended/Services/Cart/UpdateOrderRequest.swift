//
//  UpdateOrderRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 14.05.2026.
//

import Foundation

struct UpdateOrderRequest: NetworkRequest {
    let nftIDs: [String]

    init(ids: Set<String>) {
        nftIDs = ids.sorted()
    }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .put }

    var body: NetworkRequestBody? {
        .formURLEncoded(nftIDs.map { URLQueryItem(name: "nfts", value: $0) })
    }
}
