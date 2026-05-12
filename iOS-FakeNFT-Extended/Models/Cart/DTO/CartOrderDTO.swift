//
//  OrderDTO.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 09.05.2026.
//

import Foundation

struct CartOrderDTO: Decodable, Sendable {
    let id: String
    let nfts: [String]
}
