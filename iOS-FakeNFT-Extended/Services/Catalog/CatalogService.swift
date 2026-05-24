import Foundation

/// In-memory кэш коллекций по ключу `sortBy`. Без TTL — инвалидация только через pull-to-refresh.
actor CatalogService: CatalogServiceProtocol {

    // MARK: - Private

    private static let defaultCacheKey = "_default"
    private let networkClient: NetworkClient

    private var cache: [String: [NftCollection]] = [:]

    // MARK: - Init

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

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
}
