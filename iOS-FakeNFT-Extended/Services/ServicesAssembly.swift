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

    // MARK: - Catalog services

    // `lazy var` + `@ObservationIgnored` — чтобы экземпляры сервисов переживали повторные
    // обращения (иначе in-memory кэши внутри сервисов сбрасывались бы каждый раз).
    // `@Observable` превращает `var` в computed, поэтому без `@ObservationIgnored` `lazy` не работает.

    @ObservationIgnored
    private lazy var _catalogNetworkClient: NetworkClient = CatalogNetworkClient(
        inner: networkClient
    )

    @ObservationIgnored
    private lazy var _catalogService: CatalogServiceProtocol = CatalogService(
        networkClient: networkClient
    )

    var catalogService: CatalogServiceProtocol {
        _catalogService
    }

    @ObservationIgnored
    private lazy var _collectionDetailService: CollectionDetailServiceProtocol =
        CollectionDetailService(networkClient: networkClient)

    var collectionDetailService: CollectionDetailServiceProtocol {
        _collectionDetailService
    }

    @ObservationIgnored
    private lazy var _catalogFavoritesService: CatalogFavoritesServiceProtocol =
        CatalogFavoritesService(networkClient: _catalogNetworkClient)

    var catalogFavoritesService: CatalogFavoritesServiceProtocol {
        _catalogFavoritesService
    }

    @ObservationIgnored
    private lazy var _catalogCartService: CatalogCartServiceProtocol =
        CatalogCartService(networkClient: _catalogNetworkClient)

    var catalogCartService: CatalogCartServiceProtocol {
        _catalogCartService
    }
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