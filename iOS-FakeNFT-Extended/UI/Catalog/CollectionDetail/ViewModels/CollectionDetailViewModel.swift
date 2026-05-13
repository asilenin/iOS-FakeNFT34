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

    /// Коллекция, выбранная пользователем (приходит из навигации).
    let collection: NftCollection

    /// Текущее состояние загрузки.
    private(set) var state: CollectionDetailState = .loading

    /// Загруженный список NFT коллекции.
    private(set) var nfts: [Nft] = []

    /// Автор коллекции (загружается параллельно с NFT).
    private(set) var author: Author?

    /// Идентификаторы NFT, добавленных в избранное (локальное состояние P2).
    private(set) var favoriteIds: Set<String> = []

    /// Идентификаторы NFT в корзине (локальное состояние P2).
    private(set) var cartIds: Set<String> = []

    /// Ошибка последней попытки загрузки, если она была.
    /// Используется для отображения алерта через `ErrorAlert` компонент.
    var error: Error?

    private let service: CollectionDetailServiceProtocol
    private var currentTask: Task<Void, Never>?

    init(collection: NftCollection, service: CollectionDetailServiceProtocol) {
        self.collection = collection
        self.service = service
    }

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

    /// Переключить состояние избранного для указанного NFT.
    /// В P2 меняет только локальное множество; в P3 будет вызов сети.
    func toggleFavorite(_ nftId: String) {
        if favoriteIds.contains(nftId) {
            favoriteIds.remove(nftId)
        } else {
            favoriteIds.insert(nftId)
        }
    }

    /// Переключить состояние корзины для указанного NFT.
    /// В P2 меняет только локальное множество; в P3 будет вызов сети.
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
            async let loadedAuthor = service.loadAuthor(by: collection.author)
            async let loadedNfts = service.loadNfts(byIds: collection.nfts)

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
