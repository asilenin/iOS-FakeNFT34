import Foundation

/// Сервис каталога коллекций.
protocol CatalogServiceProtocol: Sendable {

    /// Загружает коллекции с серверной сортировкой. `sortBy: nil` — без сортировки.
    func loadCollections(sortBy: CatalogSortOption?) async throws -> [NftCollection]

    /// Сбрасывает кэш.
    func invalidateCache() async
}
