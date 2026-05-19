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

    // `lazy var` + `@ObservationIgnored` — чтобы экземпляры сервисов переживали повторные
    // обращения (иначе in-memory кэши внутри сервисов сбрасывались бы каждый раз).
    // `@Observable` превращает `var` в computed, поэтому без `@ObservationIgnored` `lazy` не работает.

    @ObservationIgnored
    private lazy var _catalogNetworkClient: NetworkClient = CatalogNetworkClient(
        inner: networkClient
    )

    @ObservationIgnored
    private lazy var _catalogService: CatalogServiceProtocol = CatalogService(networkClient: networkClient)
    var catalogService: CatalogServiceProtocol { _catalogService }

    @ObservationIgnored
    private lazy var _collectionDetailService: CollectionDetailServiceProtocol = CollectionDetailService(networkClient: networkClient)
    var collectionDetailService: CollectionDetailServiceProtocol { _collectionDetailService }

    @ObservationIgnored
    private lazy var _catalogFavoritesService: CatalogFavoritesServiceProtocol =
    CatalogFavoritesService(networkClient: _catalogNetworkClient)
    var catalogFavoritesService: CatalogFavoritesServiceProtocol { _catalogFavoritesService }

    @ObservationIgnored
    private lazy var _catalogCartService: CatalogCartServiceProtocol =
    CatalogCartService(networkClient: _catalogNetworkClient)
    var catalogCartService: CatalogCartServiceProtocol { _catalogCartService }
}
