import Foundation

/// Сервис избранного каталога.
protocol CatalogFavoritesServiceProtocol: Sendable {

    /// Загружает избранное. Кэширует результат до `invalidateCache`.
    func loadFavorites() async throws -> Set<String>

    /// Заменяет лайки на сервере **целиком** и возвращает обновлённое множество.
    /// Пустой `ids` очищает последний лайк через `likes=null` (ограничение mock-сервера).
    func setFavorites(_ ids: Set<String>) async throws -> Set<String>

    /// Сбрасывает кэш.
    func invalidateCache() async
}
