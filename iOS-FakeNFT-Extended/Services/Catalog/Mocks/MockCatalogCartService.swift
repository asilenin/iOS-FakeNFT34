import Foundation

/// Мок `CatalogCartServiceProtocol` для Preview и тестов. Имитирует задержку сети.
actor MockCatalogCartService: CatalogCartServiceProtocol {

    private var cart: Set<String>

    init(initialCart: Set<String> = []) {
        self.cart = initialCart
    }

    func loadCart() async throws -> Set<String> {
        try await Task.sleep(for: .milliseconds(200))
        return cart
    }

    func setCart(_ ids: Set<String>) async throws -> Set<String> {
        try await Task.sleep(for: .milliseconds(200))
        cart = ids
        return cart
    }

    func invalidateCache() {}
}
