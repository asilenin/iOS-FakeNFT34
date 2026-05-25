//
//  CartCurrencyDTO.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

struct CartCurrencyDTO: Decodable, Sendable {
    let id: String
    let title: String
    let name: String
    let image: String
}
