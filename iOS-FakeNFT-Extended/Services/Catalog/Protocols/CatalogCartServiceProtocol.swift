import Foundation

/// Сервис корзины каталога.
protocol CatalogCartServiceProtocol: Sendable {

    /// Загружает корзину. Кэширует результат до `invalidateCache`.
    func loadCart() async throws -> Set<String>

    /// Заменяет корзину на сервере **целиком** и возвращает обновлённое множество.
    /// Пустой `ids` не очищает корзину (ограничение mock-сервера, см. `OrderSetNftsRequest`).
    func setCart(_ ids: Set<String>) async throws -> Set<String>

    /// Сбрасывает кэш.
    func invalidateCache() async
}
