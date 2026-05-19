import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Shared services

    @ObservationIgnored
    private lazy var _favoritesService: FavoritesServiceProtocol = FavoritesService(
        networkClient: networkClient
    )
    var favoritesService: FavoritesServiceProtocol { _favoritesService }

    @ObservationIgnored
    private lazy var _cartService: CartServiceProtocol = CartService(
        networkClient: networkClient
    )
    var cartService: CartServiceProtocol { _cartService }

    // MARK: - Epics services

    @ObservationIgnored
    private lazy var _statisticsService: StatisticsServiceProtocol = StatisticsService(
        networkClient: networkClient
    )
    var statisticsService: StatisticsServiceProtocol { _statisticsService }
}
