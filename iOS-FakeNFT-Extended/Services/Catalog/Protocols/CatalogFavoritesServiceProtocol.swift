import Foundation

/// Сервис избранного каталога.
protocol CatalogFavoritesServiceProtocol: Sendable {

    /// Загружает избранное. Кэширует результат до `invalidateCache`.
    func loadFavorites() async throws -> Set<String>

    /// Заменяет лайки на сервере **целиком** и возвращает обновлённое множество.
    /// Пустой `ids` не очищает лайки (ограничение mock-сервера, см. `ProfileSetLikesRequest`).
    func setFavorites(_ ids: Set<String>) async throws -> Set<String>

    /// Сбрасывает кэш.
    func invalidateCache() async
}
