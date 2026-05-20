//
//  PaymentServiceProtocol.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

protocol PaymentServiceProtocol: Sendable {
    func loadCurrencies() async throws -> [PaymentCurrency]
    func pay(currencyID: String) async throws
}
