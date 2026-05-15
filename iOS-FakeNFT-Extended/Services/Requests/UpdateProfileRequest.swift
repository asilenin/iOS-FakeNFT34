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

    var httpBody: Data? {
        formItems
            .map { key, value in
                "\(key.formEncoded)=\(value.formEncoded)"
            }
            .joined(separator: "&")
            .data(using: .utf8)
    }

    var contentType: String? {
        "application/x-www-form-urlencoded"
    }

    private var formItems: [(String, String)] {
        [
            ("name", profile.name ?? ""),
            ("description", profile.description ?? ""),
            ("avatar", profile.avatar ?? ""),
            ("website", profile.website ?? "")
        ] + (profile.likes ?? []).map { ("likes", $0) }
    }
}

private extension String {
    var formEncoded: String {
        var allowedCharacters = CharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn: "&+=")

        return addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }
}
