import Foundation

/// Реальная реализация `CatalogServiceProtocol`, ходящая в mock-сервер Practicum.
///
/// Поддерживает in-memory кэш, кэшированный по ключу сортировки `sortBy`:
/// повторный запрос с тем же `sortBy` отдаёт результат из памяти без сети.
/// Кэш сбрасывается через `invalidateCache()` (вызывается из pull-to-refresh).
/// TTL у кэша нет — каталог редко меняется, и явный refresh пользователем
/// проще и предсказуемее, чем фоновое устаревание.
actor CatalogService: CatalogServiceProtocol {

    private let networkClient: NetworkClient

    /// Ключ — `apiSortKey` (или `"_default"` для `nil`).
    /// Значение — последний загруженный массив коллекций для этого ключа.
    private var cache: [String: [NftCollection]] = [:]

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCollections(sortBy: CatalogSortOption?) async throws -> [NftCollection] {
        let cacheKey = sortBy?.apiSortKey ?? Self.defaultCacheKey

        if let cached = cache[cacheKey] {
            return cached
        }

        let request = CollectionsRequest(sortBy: sortBy?.apiSortKey)
        let collections: [NftCollection] = try await networkClient.send(request: request)
        cache[cacheKey] = collections
        return collections
    }

    func invalidateCache() {
        cache.removeAll()
    }

    // MARK: - Private

    private static let defaultCacheKey = "_default"
}
