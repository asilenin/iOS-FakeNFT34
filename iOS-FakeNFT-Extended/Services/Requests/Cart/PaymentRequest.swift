//
//  PaymentRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

struct PaymentRequest: NetworkRequest {
    let currencyID: String

    var endpoint: URL? {
        URL(
            string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyID)"
        )
    }

    // API.html and Postman collection describe this endpoint as GET.
    var httpMethod: HttpMethod { .get }
}
