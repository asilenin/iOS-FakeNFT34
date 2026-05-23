//
//  PaymentViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 17.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class PaymentViewModel {
    private(set) var state: CartScreenState = .idle
    private(set) var currencies: [PaymentCurrency] = []
    private(set) var isPaying = false
    var selectedCurrency: PaymentCurrency?
    var error: Error?

    private var lastPaymentCurrencyID: String?

    var canPay: Bool {
        selectedCurrency != nil && !isPaying
    }

    func loadIfNeeded(service: PaymentServiceProtocol) async {
        guard state == .idle else { return }
        await load(service: service)
    }

    func load(service: PaymentServiceProtocol) async {
        state = .loading
        error = nil
        selectedCurrency = nil
        lastPaymentCurrencyID = nil

        do {
            currencies = try await service.loadCurrencies()
            state = .loaded
        } catch {
            currencies = []
            self.error = error
            state = .error
        }
    }

    func select(_ currency: PaymentCurrency) {
        selectedCurrency = currency
    }

    func pay(
        paymentService: PaymentServiceProtocol,
        cartService: CartServiceProtocol,
        profileService: ProfileServiceProtocol
    ) async {
        guard let selectedCurrency, !isPaying else { return }

        await pay(
            currencyID: selectedCurrency.id,
            paymentService: paymentService,
            cartService: cartService,
            profileService: profileService
        )
    }

    func retryPayment(
        paymentService: PaymentServiceProtocol,
        cartService: CartServiceProtocol,
        profileService: ProfileServiceProtocol
    ) async {
        guard let lastPaymentCurrencyID else {
            await load(service: paymentService)
            return
        }

        await pay(
            currencyID: lastPaymentCurrencyID,
            paymentService: paymentService,
            cartService: cartService,
            profileService: profileService
        )
    }

    private func pay(
        currencyID: String,
        paymentService: PaymentServiceProtocol,
        cartService: CartServiceProtocol,
        profileService: ProfileServiceProtocol
    ) async {
        isPaying = true
        error = nil
        lastPaymentCurrencyID = currencyID

        do {
            let purchasedNFTIds = try await cartService.loadCart()

            try await paymentService.pay(currencyID: currencyID)

            let profile = try await profileService.loadProfile()
            let updatedNFTIds = Set(profile.nfts ?? []).union(purchasedNFTIds)
            let updatedProfile = profile.updatingNFTs(Array(updatedNFTIds))

            _ = try await profileService.updateProfile(updatedProfile)

            try await cartService.setCart([])

            state = .success
            lastPaymentCurrencyID = nil
        } catch {
            self.error = error
        }

        isPaying = false
    }
}
