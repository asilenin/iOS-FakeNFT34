import Foundation

/// Мок-реализация `CatalogCartServiceProtocol` для разработки UI без сети.
///
/// Хранит корзину в памяти, имитирует задержку сети. Используется в Preview
/// `CollectionDetailView` и в качестве fixture-замены сервиса в тестах ViewModel.
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
