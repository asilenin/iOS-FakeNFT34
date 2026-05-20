//
//  GetUsersRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

struct GetUsersRequest: NetworkRequest {
    let page: Int
    let size: Int

    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL + "/api/v1/users")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        return components?.url
    }
}
