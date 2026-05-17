import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let cartServiceStorage: CartServiceProtocol
    private let paymentServiceStorage: PaymentServiceProtocol
    private let favoritesServiceStorage: FavoritesServiceProtocol

    private let useMockCart = true

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient

        if useMockCart {
            cartServiceStorage = MockCartService()
        } else {
            cartServiceStorage = CartService(networkClient: networkClient)
        }

        paymentServiceStorage = PaymentService(networkClient: networkClient)
        favoritesServiceStorage = NoOpFavoritesService()
    }

    // MARK: - Shared services

    var favoritesService: FavoritesServiceProtocol {
        favoritesServiceStorage
    }

    var cartService: CartServiceProtocol {
        cartServiceStorage
    }

    var paymentService: PaymentServiceProtocol {
        paymentServiceStorage
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
