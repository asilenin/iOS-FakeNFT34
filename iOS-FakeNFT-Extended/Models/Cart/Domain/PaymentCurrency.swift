//
//  PaymentCurrency.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

struct PaymentCurrency: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let name: String
    let imageURL: URL?
}

extension PaymentCurrency {
    init(dto: CartCurrencyDTO) {
        self.init(
            id: dto.id,
            title: dto.title,
            name: dto.name,
            imageURL: URL(string: dto.image)
        )
    }
}
