import Foundation

/// Мок-реализация `CatalogFavoritesServiceProtocol` для разработки UI без сети.
///
/// Хранит лайки в памяти, имитирует задержку сети. Используется в Preview
/// `CollectionDetailView` и в качестве fixture-замены сервиса в тестах ViewModel.
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
