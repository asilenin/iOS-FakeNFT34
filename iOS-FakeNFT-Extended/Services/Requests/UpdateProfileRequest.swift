//
//  UpdateProfileRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Foundation

struct UpdateProfileRequest: NetworkRequest {
    let profile: Profile

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod {
        .put
    }

    var body: NetworkRequestBody? {
        .formURLEncoded(
            formItems.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        )
    }

    private var formItems: [(String, String)] {
        [
            ("name", profile.name ?? ""),
            ("description", profile.description ?? ""),
            ("avatar", profile.avatar ?? ""),
            ("website", profile.website ?? "")
        ] + likesFormItems
    }

    private var likesFormItems: [(String, String)] {
        guard let likes = profile.likes else { return [] }
        guard !likes.isEmpty else { return [("likes", Constants.emptyLikesValue)] }

        return likes.map { ("likes", $0) }
    }

    private enum Constants {
        static let emptyLikesValue = "null"
    }
}
