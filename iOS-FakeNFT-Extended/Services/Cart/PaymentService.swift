//
//  PaymentService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation

enum PaymentServiceError: Error {
    case unsuccessfulPayment
}

actor PaymentService: PaymentServiceProtocol {
    private let networkClient: NetworkClient

    #if DEBUG
    private let shouldSimulatePaymentError = false
    #endif

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCurrencies() async throws -> [PaymentCurrency] {
        let dto: [CartCurrencyDTO] = try await networkClient.send(
            request: LoadCurrenciesRequest()
        )

        return dto.map(PaymentCurrency.init(dto:))
    }

    func pay(currencyID: String) async throws {
        #if DEBUG
        if shouldSimulatePaymentError {
            throw PaymentServiceError.unsuccessfulPayment
        }
        #endif

        let response: PaymentResponseDTO = try await networkClient.send(
            request: PaymentRequest(currencyID: currencyID)
        )

        guard response.success else {
            throw PaymentServiceError.unsuccessfulPayment
        }
    }
}
