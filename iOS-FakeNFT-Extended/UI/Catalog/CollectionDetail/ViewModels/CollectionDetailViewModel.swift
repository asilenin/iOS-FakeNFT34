import Foundation

/// ViewModel экрана коллекции NFT.
///
/// Отвечает за параллельную загрузку автора и списка NFT коллекции,
/// а также за локальное состояние избранного и корзины.
/// Данные автора (имя, сайт) приходят в составе `NftCollection` — отдельная
/// сетевая загрузка не нужна, `Author` собирается синхронно в `init`.
@Observable
@MainActor
final class CollectionDetailViewModel {

    // MARK: - Dependencies

    let collection: NftCollection

    // MARK: - State

    private(set) var state: CollectionDetailState = .loading
    private(set) var nfts: [Nft] = []

    /// Автор коллекции. Собирается из полей `NftCollection.author`/`website` в `init`,
    /// потому что mock-сервер отдаёт эти данные внутри коллекции, а отдельной
    /// ручки `/users/{id}` для авторов нет.
    let author: Author

    /// Бинди́тся в `errorAlert` modifier во View.
    var error: Error?

    // Множества state НЕ читаются View напрямую — только через
    // `isFavorite(_:)` / `isInCart(_:)`. `private(set)` сохранён для того,
    // чтобы `@Observable` мог отслеживать изменения и триггерить ре-рендер.
    private(set) var favoriteIds: Set<String> = []
    private(set) var cartIds: Set<String> = []

    // MARK: - Internal

    private let service: CollectionDetailServiceProtocol
    private var currentTask: Task<Void, Never>?

    // MARK: - Init

    init(collection: NftCollection, service: CollectionDetailServiceProtocol) {
        self.collection = collection
        self.service = service
        self.author = Author(
            // Используем имя автора как идентификатор: серверный id автора недоступен
            // в ответе `/collections`, а имя по соглашению API уникально в рамках коллекции.
            id: collection.author ?? "",
            name: collection.author ?? "",
            website: collection.website?.absoluteString ?? ""
        )
    }

    // MARK: - Public Queries

    func isFavorite(_ nftId: String) -> Bool {
        favoriteIds.contains(nftId)
    }

    func isInCart(_ nftId: String) -> Bool {
        cartIds.contains(nftId)
    }

    /// URL для перехода на сайт автора.
    /// Возвращает `nil`, если website пустой или невалидный.
    var authorURL: URL? {
        guard !author.website.isEmpty else { return nil }
        return URL(string: author.website)
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

    func didTapFavorite(_ nftId: String) {
        toggleFavorite(nftId)
    }

    func didTapCart(_ nftId: String) {
        toggleCart(nftId)
    }

    // MARK: - Private

    private func toggleFavorite(_ nftId: String) {
        if favoriteIds.contains(nftId) {
            favoriteIds.remove(nftId)
        } else {
            favoriteIds.insert(nftId)
        }
    }

    private func toggleCart(_ nftId: String) {
        if cartIds.contains(nftId) {
            cartIds.remove(nftId)
        } else {
            cartIds.insert(nftId)
        }
    }

    private func performLoad(
        using service: CollectionDetailServiceProtocol,
        for collection: NftCollection
    ) async {
        state = .loading
        do {
            let nfts = try await service.loadNfts(byIds: collection.nfts ?? [])
            try Task.checkCancellation()

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
