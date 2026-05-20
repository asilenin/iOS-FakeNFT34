import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let catalogNetworkClient: CatalogNetworkClient
    private let cartServiceStorage: CartServiceProtocol
    private let paymentServiceStorage: PaymentServiceProtocol
    private let favoritesServiceStorage: FavoritesServiceProtocol

    private let useMockCart = false

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        self.catalogNetworkClient = CatalogNetworkClient(inner: networkClient)

        if useMockCart {
            cartServiceStorage = MockCartService()
        } else {
            cartServiceStorage = CartService(networkClient: networkClient)
        }

        paymentServiceStorage = PaymentService(networkClient: networkClient)
        favoritesServiceStorage = FavoritesService(networkClient: catalogNetworkClient)
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

    // MARK: - Statistics

    @ObservationIgnored
    private lazy var _statisticsService: StatisticsServiceProtocol = StatisticsService(
        networkClient: networkClient
    )

    var statisticsService: StatisticsServiceProtocol {
        _statisticsService
    }

    // MARK: - Catalog services

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
        CatalogFavoritesService(networkClient: catalogNetworkClient)

    var catalogFavoritesService: CatalogFavoritesServiceProtocol {
        _catalogFavoritesService
    }

    @ObservationIgnored
    private lazy var _catalogCartService: CatalogCartServiceProtocol =
        CatalogCartService(networkClient: catalogNetworkClient)

    var catalogCartService: CatalogCartServiceProtocol {
        _catalogCartService
    }
}
