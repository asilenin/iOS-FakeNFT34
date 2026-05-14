import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Shared services
    var favoritesService: FavoritesServiceProtocol {
        // TODO: replace with the real actor implementation
        // (e.g. FavoritesService(networkClient: networkClient)) once the owning epic delivers it.
        fatalError("FavoritesService is not wired yet — see B2.6")
    }
    
    var cartService: CartServiceProtocol {
        // TODO: replace with the real actor implementation
        // (e.g. CartService(networkClient: networkClient)) once the owning epic delivers it.
        fatalError("CartService is not wired yet — see B2.6")
    }

    // MARK: - Epics services
    // Each epic registers its services here as it lands:
    //   - Catalog:    catalogService, collectionDetailService
    //   - Cart:       ordersService, currenciesService
    //   - Profile:    profileService
    //   - Statistics: usersService

    var profileService: ProfileServiceProtocol {
        ProfileService(networkClient: networkClient)
    }
}
