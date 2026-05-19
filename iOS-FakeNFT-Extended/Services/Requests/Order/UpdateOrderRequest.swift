//
//  UpdateOrderRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

struct UpdateOrderRequest: NetworkRequest {
    let nftIds: Set<String>

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(RequestConstants.orderId)")
    }

    var httpMethod: HttpMethod { .put }

    var formParameters: [String: String]? {
        ["nfts": NetworkIdListParser.joined(nftIds)]
    }
}
