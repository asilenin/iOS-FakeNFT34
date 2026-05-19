//
//  GetUserRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

struct GetUserRequest: NetworkRequest {
    let userId: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users/\(userId)")
    }
}
