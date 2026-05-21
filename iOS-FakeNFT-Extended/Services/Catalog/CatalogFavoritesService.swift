import Foundation

/// In-memory кэш набора лайков. Обновляется на `loadFavorites`/`setFavorites`,
/// инвалидируется через `invalidateCache`.
actor CatalogFavoritesService: CatalogFavoritesServiceProtocol {

    // MARK: - Private

    private let networkClient: NetworkClient
    private var cached: Set<String>?

    // MARK: - Init

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

    func loadFavorites() async throws -> Set<String> {
        if let cached {
            print("ℹ️ [\(fileName())]: :\(#line)] \(#function) cache hit, \(cached.count) likes")
            return cached
        }
        let request = ProfileRequest()
        print("ℹ️ [\(fileName())]: :\(#line)] \(#function) GET \(request.endpoint?.absoluteString ?? "nil")")

        do {
            let profile: CatalogProfileDto = try await networkClient.send(request: request)
            let favorites = Set(profile.likes)
            cached = favorites
            print("ℹ️ [\(fileName())]: :\(#line)] \(#function) loaded \(favorites.count) likes")
            return favorites
        } catch {
            print("❌ [\(fileName())]: :\(#line)] \(#function) failed: \(error)")
            throw error
        }
    }

    func setFavorites(_ ids: Set<String>) async throws -> Set<String> {
        let request = ProfileSetLikesRequest(likes: Array(ids))
        print("ℹ️ [\(fileName())]: :\(#line)] \(#function) PUT \(request.endpoint?.absoluteString ?? "nil") with \(ids.count) likes")

        do {
            let profile: CatalogProfileDto = try await networkClient.send(request: request)
            let updated = Set(profile.likes)
            cached = updated
            print("ℹ️ [\(fileName())]: :\(#line)] \(#function) server returned \(updated.count) likes")
            return updated
        } catch {
            print("❌ [\(fileName())]: :\(#line)] \(#function) failed: \(error)")
            throw error
        }
    }

    func invalidateCache() {
        cached = nil
    }
}
