import Foundation

/// Реальная реализация `CatalogFavoritesServiceProtocol`, ходящая в mock-сервер.
///
/// In-memory кэш: единый `Set<String>` хранит последний загруженный/сохранённый
/// набор лайков. Кэш обновляется при `loadFavorites` (из GET-ответа) и при
/// `setFavorites` (из PUT-ответа). Инвалидируется через `invalidateCache`
/// (вызывается из pull-to-refresh во ViewModel).
actor CatalogFavoritesService: CatalogFavoritesServiceProtocol {

    private let networkClient: NetworkClient
    private var cached: Set<String>?

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadFavorites() async throws -> Set<String> {
        if let cached {
            return cached
        }
        let profile: CatalogProfileDto = try await networkClient.send(request: ProfileGetRequest())
        let favorites = Set(profile.likes)
        cached = favorites
        return favorites
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        let request = ProfileSetLikesRequest(likes: Array(ids))
        let profile: CatalogProfileDto = try await networkClient.send(request: request)
        let updated = Set(profile.likes)
        cached = updated
        return updated
    }

    func invalidateCache() {
        cached = nil
    }
}
