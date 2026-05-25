import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let catalogNetworkClient: CatalogNetworkClient
    private let cartServiceStorage: CartServiceProtocol
    private let paymentServiceStorage: PaymentServiceProtocol
    private let favoritesServiceStorage: FavoritesServiceProtocol
    private let profileServiceStorage: ProfileServiceProtocol

    private let useMockCart = false

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        self.catalogNetworkClient = CatalogNetworkClient(inner: networkClient)

        if useMockCart {
            cartServiceStorage = MockCartService()
        } else {
            cartServiceStorage = CartService(
                networkClient: networkClient,
                catalogNetworkClient: catalogNetworkClient
            )
        }

        paymentServiceStorage = PaymentService(networkClient: networkClient)

        let profile = ProfileService(networkClient: networkClient)
        profileServiceStorage = profile
        favoritesServiceStorage = FavoritesService(profileService: profile)
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

    var profileService: ProfileServiceProtocol {
        profileServiceStorage
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

    // MARK: - Profile

    @ObservationIgnored
    private lazy var _nftService: NftServiceProtocol = NftService(
        networkClient: networkClient
    )

    var nftService: NftServiceProtocol {
        _nftService
    }
}
