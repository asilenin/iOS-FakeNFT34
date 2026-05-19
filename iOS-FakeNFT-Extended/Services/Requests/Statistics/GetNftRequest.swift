//
//  GetNftRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 19.05.2026.
//

import Foundation

struct GetNftRequest: NetworkRequest {
    let nftId: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(nftId)")
    }
}
