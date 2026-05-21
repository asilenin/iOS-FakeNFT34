//
//  LoadCurrenciesRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

struct LoadCurrenciesRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
}
