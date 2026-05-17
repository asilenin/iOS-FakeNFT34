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

    // Real services are stored as `lazy var` so the same actor instance survives across
    // multiple accesses. Critical for the in-memory caches inside the services —
    // a fresh computed-property instance per access would reset the cache on every read.
    // @ObservationIgnored is required because @Observable converts vars to computed,
    // which conflicts with `lazy`.

    @ObservationIgnored
    private lazy var _catalogService: CatalogServiceProtocol = CatalogService(networkClient: networkClient)
    var catalogService: CatalogServiceProtocol { _catalogService }

    @ObservationIgnored
    private lazy var _collectionDetailService: CollectionDetailServiceProtocol = CollectionDetailService(networkClient: networkClient)
    var collectionDetailService: CollectionDetailServiceProtocol { _collectionDetailService }

}
