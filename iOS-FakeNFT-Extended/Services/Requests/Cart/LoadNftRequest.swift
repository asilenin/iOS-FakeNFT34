//
//  LoadNftRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 09.05.2026.
//

import Foundation

struct LoadNftRequest: NetworkRequest {
    let nftID: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(nftID)")
    }
}
