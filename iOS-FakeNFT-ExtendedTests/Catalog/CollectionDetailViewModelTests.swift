import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class CollectionDetailViewModelTests: XCTestCase {

    // MARK: - Helpers

    private static func makeCollection(nftIds: [String] = ["nft-1", "nft-2"]) -> NftCollection {
        NftCollection(
            id: "collection-1",
            name: "Test Collection",
            cover: nil,
            nfts: nftIds,
            description: nil,
            author: "Test Author",
            website: URL(string: "https://example.com"),
            createdAt: nil
        )
    }

    private static func makeNft(id: String) -> Nft {
        Nft(
            id: id,
            createdAt: nil,
            name: "NFT \(id)",
            images: nil,
            rating: 3,
            description: nil,
            price: 1.0,
            author: nil,
            website: nil
        )
    }

    private func makeViewModel(
        collection: NftCollection? = nil,
        service: CollectionDetailServiceProtocol? = nil,
        favoritesService: CatalogFavoritesServiceProtocol? = nil,
        cartService: CatalogCartServiceProtocol? = nil
    ) -> CollectionDetailViewModel {
        CollectionDetailViewModel(
            collection: collection ?? Self.makeCollection(),
            service: service ?? StubCollectionDetailService(nfts: [Self.makeNft(id: "nft-1")]),
            favoritesService: favoritesService ?? StubFavoritesService(),
            cartService: cartService ?? StubCartService()
        )
    }
    
    /// Создаёт ViewModel и сразу вызывает `load()`. Использовать в тестах,
    /// которым нужно загруженное состояние и не важен переход loading → success.
    private func makeLoadedViewModel(
        collection: NftCollection? = nil,
        service: CollectionDetailServiceProtocol? = nil,
        favoritesService: CatalogFavoritesServiceProtocol? = nil,
        cartService: CatalogCartServiceProtocol? = nil
    ) async -> CollectionDetailViewModel {
        let viewModel = makeViewModel(
            collection: collection,
            service: service,
            favoritesService: favoritesService,
            cartService: cartService
        )
        await viewModel.load()
        return viewModel
    }

    private func assertState(
        _ state: CollectionDetailState,
        equals expected: CollectionDetailState,
        line: UInt = #line
    ) {
        switch (state, expected) {
        case (.loading, .loading), (.success, .success), (.error, .error):
            return
        default:
            XCTFail("Expected state \(expected), got \(state)", line: line)
        }
    }

    // MARK: - load() — combined parallel flow

    func test_load_successfulFlow_populatesAllThreeStates() async {
        let favorites = StubFavoritesService(initial: ["nft-1"])
        let cart = StubCartService(initial: ["nft-2"])
        let viewModel = makeViewModel(
            service: StubCollectionDetailService(nfts: [Self.makeNft(id: "nft-1"), Self.makeNft(id: "nft-2")]),
            favoritesService: favorites,
            cartService: cart
        )

        await viewModel.load()

        assertState(viewModel.state, equals: .success)
        XCTAssertEqual(Set(viewModel.nfts.map(\.id)), ["nft-1", "nft-2"])
        XCTAssertEqual(viewModel.favoriteIds, ["nft-1"])
        XCTAssertEqual(viewModel.cartIds, ["nft-2"])
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.favoritesError)
        XCTAssertNil(viewModel.cartError)
    }

    func test_load_nftFailure_setsErrorState_doesNotTouchFavoritesOrCart() async {
        let viewModel = makeViewModel(
            service: StubCollectionDetailService(error: TestError(message: "nft failed"))
        )

        await viewModel.load()

        assertState(viewModel.state, equals: .error)
        XCTAssertNotNil(viewModel.error)
        XCTAssertNil(viewModel.favoritesError)
        XCTAssertNil(viewModel.cartError)
    }

    func test_load_favoritesFailure_doesNotFailScreen_setsOnlyFavoritesError() async {
        let favorites = StubFavoritesService()
        await favorites.setLoadError(TestError(message: "fav load"))
        let viewModel = makeViewModel(favoritesService: favorites)

        await viewModel.load()

        assertState(viewModel.state, equals: .success)
        XCTAssertNotNil(viewModel.favoritesError)
        XCTAssertNil(viewModel.cartError)
    }

    func test_load_cartFailure_doesNotFailScreen_setsOnlyCartError() async {
        let cart = StubCartService()
        await cart.setLoadError(TestError(message: "cart load"))
        let viewModel = makeViewModel(cartService: cart)

        await viewModel.load()

        assertState(viewModel.state, equals: .success)
        XCTAssertNotNil(viewModel.cartError)
        XCTAssertNil(viewModel.favoritesError)
    }

    // MARK: - toggleFavorite — optimistic update

    func test_didTapFavorite_addsIdOptimistically_andCallsService() async {
        let favorites = StubFavoritesService()
        let viewModel = await makeLoadedViewModel(favoritesService: favorites)

        await viewModel.didTapFavorite("nft-1")

        XCTAssertTrue(viewModel.isFavorite("nft-1"))
        let setCalls = await favorites.setCalls
        XCTAssertEqual(setCalls, [["nft-1"]])
    }

    func test_didTapFavorite_existingId_removesIt() async {
        let favorites = StubFavoritesService(initial: ["nft-1"])
        let viewModel = await makeLoadedViewModel(favoritesService: favorites)

        await viewModel.didTapFavorite("nft-1")

        XCTAssertFalse(viewModel.isFavorite("nft-1"))
    }

    func test_didTapFavorite_serviceFails_rollsBackStateAndSetsError() async {
        let favorites = StubFavoritesService(initial: ["nft-1"])
        let viewModel = await makeLoadedViewModel(favoritesService: favorites)
        await favorites.setSetError(TestError(message: "PUT failed"))

        await viewModel.didTapFavorite("nft-2")

        XCTAssertFalse(viewModel.isFavorite("nft-2"), "Optimistic add must be rolled back on error")
        XCTAssertTrue(viewModel.isFavorite("nft-1"), "Previous favorites must remain intact")
        XCTAssertNotNil(viewModel.favoritesError)
    }

    func test_didTapFavorite_whenDisabled_doesNothing() async {
        let favorites = StubFavoritesService()
        let viewModel = await makeLoadedViewModel(favoritesService: favorites)
        viewModel.disableFavorites()

        await viewModel.didTapFavorite("nft-1")

        XCTAssertFalse(viewModel.isFavorite("nft-1"))
        let setCalls = await favorites.setCalls
        XCTAssertTrue(setCalls.isEmpty, "Service must not be called when favorites disabled")
    }

    // MARK: - toggleCart — optimistic update

    func test_didTapCart_addsIdOptimistically_andCallsService() async {
        let cart = StubCartService()
        let viewModel = await makeLoadedViewModel(cartService: cart)

        await viewModel.didTapCart("nft-1")

        XCTAssertTrue(viewModel.isInCart("nft-1"))
        let setCalls = await cart.setCalls
        XCTAssertEqual(setCalls, [["nft-1"]])
    }

    func test_didTapCart_serviceFails_rollsBackStateAndSetsError() async {
        let cart = StubCartService(initial: ["nft-1"])
        let viewModel = await makeLoadedViewModel(cartService: cart)
        await cart.setSetError(TestError(message: "PUT failed"))

        await viewModel.didTapCart("nft-2")

        XCTAssertFalse(viewModel.isInCart("nft-2"))
        XCTAssertTrue(viewModel.isInCart("nft-1"))
        XCTAssertNotNil(viewModel.cartError)
    }

    func test_didTapCart_whenDisabled_doesNothing() async {
        let cart = StubCartService()
        let viewModel = await makeLoadedViewModel(cartService: cart)
        viewModel.disableCart()

        await viewModel.didTapCart("nft-1")

        XCTAssertFalse(viewModel.isInCart("nft-1"))
        let setCalls = await cart.setCalls
        XCTAssertTrue(setCalls.isEmpty)
    }

    // MARK: - retry / disable

    func test_retryLoadFavorites_successAfterError_clearsError() async {
        let favorites = StubFavoritesService()
        await favorites.setLoadError(TestError(message: "first attempt"))
        let viewModel = makeViewModel(favoritesService: favorites)
        await viewModel.load()
        XCTAssertNotNil(viewModel.favoritesError)

        await favorites.setLoadError(nil)
        await favorites.setStored(["nft-1"])
        await viewModel.retryLoadFavorites()

        XCTAssertNil(viewModel.favoritesError)
        XCTAssertEqual(viewModel.favoriteIds, ["nft-1"])
    }

    func test_retryLoadCart_successAfterError_clearsError() async {
        let cart = StubCartService()
        await cart.setLoadError(TestError(message: "first"))
        let viewModel = makeViewModel(cartService: cart)
        await viewModel.load()
        XCTAssertNotNil(viewModel.cartError)

        await cart.setLoadError(nil)
        await cart.setStored(["nft-1"])
        await viewModel.retryLoadCart()

        XCTAssertNil(viewModel.cartError)
        XCTAssertEqual(viewModel.cartIds, ["nft-1"])
    }

    func test_disableFavorites_setsFlagAndClearsError() async {
        let viewModel = makeViewModel()
        viewModel.favoritesError = TestError(message: "x")

        viewModel.disableFavorites()

        XCTAssertTrue(viewModel.favoritesDisabled)
        XCTAssertNil(viewModel.favoritesError)
    }

    func test_disableCart_setsFlagAndClearsError() async {
        let viewModel = makeViewModel()
        viewModel.cartError = TestError(message: "x")

        viewModel.disableCart()

        XCTAssertTrue(viewModel.cartDisabled)
        XCTAssertNil(viewModel.cartError)
    }

    func test_reload_clearsDisabledFlags() async {
        let viewModel = makeViewModel()
        viewModel.disableFavorites()
        viewModel.disableCart()

        await viewModel.reload()

        XCTAssertFalse(viewModel.favoritesDisabled)
        XCTAssertFalse(viewModel.cartDisabled)
    }
}
