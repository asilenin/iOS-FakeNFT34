import Foundation

/// Мок `CatalogFavoritesServiceProtocol` для Preview и тестов. Имитирует задержку сети.
actor MockCatalogFavoritesService: CatalogFavoritesServiceProtocol {

    private var favorites: Set<String>

    init(initialFavorites: Set<String> = []) {
        self.favorites = initialFavorites
    }

    func loadFavorites() async throws -> Set<String> {
        try await Task.sleep(for: .milliseconds(200))
        return favorites
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        try await Task.sleep(for: .milliseconds(200))
        favorites = ids
        return favorites
    }

    func invalidateCache() {}
}
