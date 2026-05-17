import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let cartServiceStorage: CartServiceProtocol
    private let favoritesServiceStorage: FavoritesServiceProtocol

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient

        // TODO: Sprint 4 — switch Cart flow to real CartService
        // after payment integration is finished.
        cartServiceStorage = MockCartService()

        // Real implementation is ready:
        // cartServiceStorage = CartService(networkClient: networkClient)

        favoritesServiceStorage = NoOpFavoritesService()
    }

    // MARK: - Shared services

    var favoritesService: FavoritesServiceProtocol {
        favoritesServiceStorage
    }

    var cartService: CartServiceProtocol {
        cartServiceStorage
    }

    // MARK: - Epics services
    // Each epic registers its services here as it lands:
    //   - Catalog:    catalogService, collectionDetailService
    //   - Cart:       cartService, paymentService
    //   - Profile:    profileService
    //   - Statistics: usersService
}

private actor NoOpFavoritesService: FavoritesServiceProtocol {
    private var ids: Set<String> = []

    func loadFavorites() async throws -> Set<String> {
        ids
    }

    func setFavorites(_ ids: Set<String>) async throws {
        self.ids = ids
    }
}
