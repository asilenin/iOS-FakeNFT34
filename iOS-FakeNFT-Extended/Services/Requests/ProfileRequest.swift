//
//  ProfileRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 06.05.2026.
//

import Foundation

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
}
