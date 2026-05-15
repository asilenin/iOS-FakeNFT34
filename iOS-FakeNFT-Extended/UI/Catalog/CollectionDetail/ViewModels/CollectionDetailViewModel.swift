import Foundation

/// ViewModel экрана коллекции NFT.
///
/// Отвечает за параллельную загрузку автора и списка NFT коллекции,
/// а также за локальное состояние избранного и корзины.
/// В P2 множества `favoriteIds`/`cartIds` живут только в памяти;
/// в P3 будут синхронизироваться с `FavoritesService`/`CartService`.
@Observable
@MainActor
final class CollectionDetailViewModel {

    // MARK: - Dependencies

    let collection: NftCollection

    // MARK: - State

    private(set) var state: CollectionDetailState = .loading

    private(set) var nfts: [Nft] = []

    private(set) var author: Author?

    private(set) var favoriteIds: Set<String> = []

    private(set) var cartIds: Set<String> = []

    /// Бинди́тся в `errorAlert` modifier во View.
    var error: Error?

    // MARK: - Internal

    private let service: CollectionDetailServiceProtocol
    private var currentTask: Task<Void, Never>?

    // MARK: - Init

    init(collection: NftCollection, service: CollectionDetailServiceProtocol) {
        self.collection = collection
        self.service = service
    }

    // MARK: - Public Methods

    /// Загрузить автора и NFT параллельно.
    /// Отменяет предыдущую загрузку, если она была в процессе.
    func load() async {
        currentTask?.cancel()

        let task = Task { [service, collection] in
            await performLoad(using: service, for: collection)
        }
        currentTask = task
        await task.value
    }

    // MARK: - User Actions

    func toggleFavorite(_ nftId: String) {
        if favoriteIds.contains(nftId) {
            favoriteIds.remove(nftId)
        } else {
            favoriteIds.insert(nftId)
        }
    }

    func toggleCart(_ nftId: String) {
        if cartIds.contains(nftId) {
            cartIds.remove(nftId)
        } else {
            cartIds.insert(nftId)
        }
    }

    // MARK: - Private

    private func performLoad(
        using service: CollectionDetailServiceProtocol,
        for collection: NftCollection
    ) async {
        state = .loading
        do {
            async let loadedAuthor = service.loadAuthor(by: collection.author ?? "")
            async let loadedNfts = service.loadNfts(byIds: collection.nfts ?? [])

            let (author, nfts) = try await (loadedAuthor, loadedNfts)
            try Task.checkCancellation()

            self.author = author
            self.nfts = nfts
            self.state = .success
        } catch is CancellationError {
            return
        } catch {
            state = .error
            self.error = error
        }
    }
}
