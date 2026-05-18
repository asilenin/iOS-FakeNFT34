import Foundation

/// Реальная реализация `CatalogCartServiceProtocol`, ходящая в mock-сервер.
///
/// In-memory кэш: единый `Set<String>` хранит последний загруженный/сохранённый
/// состав корзины. Кэш обновляется при `loadCart` (из GET-ответа) и при
/// `setCart` (из PUT-ответа). Инвалидируется через `invalidateCache`
/// (вызывается из pull-to-refresh во ViewModel).
actor CatalogCartService: CatalogCartServiceProtocol {

    // MARK: - Private

    private let networkClient: NetworkClient
    private var cached: Set<String>?

    // MARK: - Init

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

    func loadCart() async throws -> Set<String> {
        if let cached {
            return cached
        }
        let order: CatalogOrderDto = try await networkClient.send(request: OrderGetRequest())
        let cart = Set(order.nfts)
        cached = cart
        return cart
    }

    func setCart(_ ids: Set<String>) async throws -> Set<String> {
        let request = OrderSetNftsRequest(nfts: Array(ids))
        let order: CatalogOrderDto = try await networkClient.send(request: request)
        let updated = Set(order.nfts)
        cached = updated
        return updated
    }

    func invalidateCache() {
        cached = nil
    }
}
