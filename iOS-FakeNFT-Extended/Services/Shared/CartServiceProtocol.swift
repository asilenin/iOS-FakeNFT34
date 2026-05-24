import Foundation

protocol CartServiceProtocol: Sendable {

    /// Загружает id NFT в корзине. Результат кэшируется до `invalidateCache()`.
    func loadCart() async throws -> Set<String>

    /// Заменяет корзину на сервере целиком и возвращает актуальное множество.
    @discardableResult
    func setCart(_ ids: Set<String>) async throws -> Set<String>

    /// Сбрасывает in-memory кэш состава корзины.
    func invalidateCache() async

    /// Загружает полные модели NFT для экрана корзины.
    func loadCartItems() async throws -> [CartItem]
}
