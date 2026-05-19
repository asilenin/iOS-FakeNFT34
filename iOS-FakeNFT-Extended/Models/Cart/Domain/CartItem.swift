//
//  CartItem.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 09.05.2026.
//

import Foundation

struct CartItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let imageURL: URL?
    let rating: Int
    let price: Double
}

extension CartItem {
    init(dto: CartNftDTO) {
        self.init(
            id: dto.id,
            title: dto.name,
            imageURL: dto.images.first.flatMap(URL.init(string:)),
            rating: dto.rating,
            price: dto.price
        )
    }
}
