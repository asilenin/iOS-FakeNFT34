import Foundation

protocol FavoritesServiceProtocol: Sendable {

    /// Загружает набор id лайкнутых NFT. Результат кэшируется до `invalidateCache()`.
    func loadFavorites() async throws -> Set<String>

    /// Заменяет лайки на сервере целиком и возвращает актуальное множество с сервера.
    /// Пустой `ids` очищает последний лайк через `likes=null` (ограничение mock-сервера).
    func setFavorites(_ ids: Set<String>) async throws -> Set<String>

    /// Сбрасывает in-memory кэш.
    func invalidateCache() async
}
