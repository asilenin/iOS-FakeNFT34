import Foundation

/// ViewModel экрана коллекции NFT.
///
/// Отвечает за загрузку списка NFT коллекции и за локальное состояние избранного и корзины.
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

    /// Ошибка загрузки/изменения избранного. Биндится в отдельный `.alert` во View,
    /// чтобы пользователь мог выбрать между "Повторить" и "Отмена".
    var favoritesError: Error?

    /// Флаг, выставленный пользователем через "Отмена" в favoritesError-алерте.
    /// Когда `true` — кнопки сердец дизейблятся, чтобы предотвратить отправку
    /// PUT с неполным состоянием (это могло бы стереть лайки на сервере).
    /// Сбрасывается при `reload()`.
    private(set) var favoritesDisabled: Bool = false

    // Множества state НЕ читаются View напрямую — только через
    // `isFavorite(_:)` / `isInCart(_:)`. `private(set)` сохранён для того,
    // чтобы `@Observable` мог отслеживать изменения и триггерить ре-рендер.
    private(set) var favoriteIds: Set<String> = []
    private(set) var cartIds: Set<String> = []

    /// id NFT, для которых сейчас идёт PUT-запрос на изменение лайка.
    /// View использует для дизейбла конкретной кнопки.
    private(set) var favoritePendingIds: Set<String> = []

    // MARK: - Internal

    private let service: CollectionDetailServiceProtocol
    private let favoritesService: CatalogFavoritesServiceProtocol
    private var currentTask: Task<Void, Never>?

    // MARK: - Init

    init(
        collection: NftCollection,
        service: CollectionDetailServiceProtocol,
        favoritesService: CatalogFavoritesServiceProtocol
    ) {
        self.collection = collection
        self.service = service
        self.favoritesService = favoritesService
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

    func isFavoritePending(_ nftId: String) -> Bool {
        favoritePendingIds.contains(nftId)
    }

    /// URL для перехода на сайт автора.
    /// Возвращает `nil`, если website пустой или невалидный.
    var authorURL: URL? {
        guard !author.website.isEmpty else { return nil }
        return URL(string: author.website)
    }

    // MARK: - Public Methods

    /// Загрузить NFT коллекции.
    /// Отменяет предыдущую загрузку, если она была в процессе.
    func load() async {
        currentTask?.cancel()

        let task = Task { [service, favoritesService, collection] in
            await performLoad(
                using: service,
                favoritesService: favoritesService,
                for: collection)
        }
        currentTask = task
        await task.value
    }

    /// Принудительно перезагружает с сервера, минуя кэш.
    /// Вызывается из pull-to-refresh.
    func reload() async {
        await service.invalidateCache()
        await favoritesService.invalidateCache()
        favoritesDisabled = false
        await load()
    }

    /// Повторная попытка загрузить только лайки.
    /// Вызывается из "Повторить" в favoritesError-алерте.
    func retryLoadFavorites() async {
        await favoritesService.invalidateCache()
        do {
            favoriteIds = try await favoritesService.loadFavorites()
            favoritesError = nil
        } catch {
            favoritesError = error
        }
    }

    /// Вызывается из "Отмена" в favoritesError-алерте.
    /// Дизейблит кнопки сердец до следующего успешного `reload`/`retryLoadFavorites`.
    func disableFavorites() {
        favoritesDisabled = true
        favoritesError = nil
    }

    // MARK: - User Actions

    func didTapFavorite(_ nftId: String) async {
        await toggleFavorite(nftId)
    }

    func didTapCart(_ nftId: String) {
        toggleCart(nftId)
    }

    // MARK: - Private

    private func toggleFavorite(_ nftId: String) async {
        guard !favoritesDisabled, !favoritePendingIds.contains(nftId) else { return }

        let previous = favoriteIds
        // Optimistic update — UI отражает новое состояние сразу.
        if favoriteIds.contains(nftId) {
            favoriteIds.remove(nftId)
        } else {
            favoriteIds.insert(nftId)
        }
        favoritePendingIds.insert(nftId)
        defer { favoritePendingIds.remove(nftId) }

        do {
            let updated = try await favoritesService.setFavorites(favoriteIds)
            favoriteIds = updated
        } catch {
            favoriteIds = previous
            favoritesError = error
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
        favoritesService: CatalogFavoritesServiceProtocol,
        for collection: NftCollection
    ) async {
        state = .loading
        // NFT — критичный поток, ошибка → экран в .error.
        // Favorites — best-effort, ошибка не валит экран, выставляет favoritesError.
        async let nftsTask = service.loadNfts(byIds: collection.nfts ?? [])
        async let favoritesTask = loadFavoritesNonThrowing(using: favoritesService)

        do {
            let nfts = try await nftsTask
            try Task.checkCancellation()
            self.nfts = nfts

            // Дождёмся favorites (без throws).
            let favoritesResult = await favoritesTask
            switch favoritesResult {
            case .success(let ids):
                self.favoriteIds = ids
            case .failure(let error):
                self.favoritesError = error
            }

            self.state = .success
        } catch is CancellationError {
            return
        } catch {
            state = .error
            self.error = error
        }
    }

    /// Обёртка над `loadFavorites`, не пробрасывающая ошибку наружу —
    /// чтобы `async let` рядом с throwing NFT-загрузкой не валил всё.
    private func loadFavoritesNonThrowing(
        using favoritesService: CatalogFavoritesServiceProtocol
    ) async -> Result<Set<String>, Error> {
        do {
            return .success(try await favoritesService.loadFavorites())
        } catch {
            return .failure(error)
        }
    }
}
