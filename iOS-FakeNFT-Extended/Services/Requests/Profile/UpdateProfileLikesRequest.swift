//
//  UpdateProfileLikesRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

struct UpdateProfileLikesRequest: NetworkRequest {
    let likes: Set<String>

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(RequestConstants.profileId)")
    }

    var httpMethod: HttpMethod { .put }

    var formParameters: [String: String]? {
        ["likes": NetworkIdListParser.joined(likes)]
    }
}
