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
        fatalError("FavoritesService is not wired yet — see B2.6")
    }

    var cartService: CartServiceProtocol {
        // TODO: replace with the real actor implementation
        fatalError("CartService is not wired yet — see B2.6")
    }

    // MARK: - Epics services

    var statisticsService: StatisticsServiceProtocol {
        MockStatisticsService()
    }
}
