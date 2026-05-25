import Foundation
@testable import iOS_FakeNFT_Extended

// Стаб платёжного сервиса с логом вызовов.
actor StubPaymentService: PaymentServiceProtocol {
    private var payError: Error?
    private(set) var payCalls: [String] = []
    private let currencies: [PaymentCurrency]

    init(currencies: [PaymentCurrency] = []) {
        self.currencies = currencies
    }

    func setPayError(_ error: Error?) { payError = error }

    func loadCurrencies() async throws -> [PaymentCurrency] { currencies }

    func pay(currencyID: String) async throws {
        payCalls.append(currencyID)
        if let payError { throw payError }
    }
}

// Стаб корзины с логом порядка вызовов и performOrder.
actor OrderTrackingCartService: CartServiceProtocol {
    private(set) var events: [String] = []
    private var stored: Set<String>
    private var loadError: Error?

    init(initial: Set<String>) { stored = initial }

    func setLoadError(_ error: Error?) { loadError = error }

    func loadCart() async throws -> Set<String> {
        events.append("loadCart")
        if let loadError { throw loadError }
        return stored
    }

    @discardableResult
    func setCart(_ ids: Set<String>) async throws -> Set<String> {
        events.append("setCart(\(ids.sorted().joined(separator: ",")))")
        stored = ids
        return stored
    }

    func invalidateCache() async { events.append("cart.invalidate") }
    func loadCartItems() async throws -> [CartItem] { [] }
    func performOrder(_ ids: Set<String>) async throws {
        events.append("performOrder(\(ids.sorted().joined(separator: ",")))")
    }
}

// Профиль с флагом инвалидации.
actor InvalidationTrackingProfileService: ProfileServiceProtocol {
    private(set) var invalidateCalled = false
    func loadProfile() async throws -> Profile { ProfilePreviewData.profile }
    func updateProfile(_ profile: Profile) async throws -> Profile { profile }
    func invalidateCache() async { invalidateCalled = true }
}
