//
//  LoadOrderRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 09.05.2026.
//

import Foundation

struct LoadOrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}
