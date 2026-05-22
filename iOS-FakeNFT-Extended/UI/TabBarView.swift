import SwiftUI

struct TabBarView: View {

    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var services

    var body: some View {
        @Bindable var router = router

        VStack(spacing: 0) {
            selectedTabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isCurrentTabPushed(router) {
                CustomTabBar(selection: $router.selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var selectedTabContent: some View {
        switch router.selectedTab {
        case .profile:
            ProfileTabRoot(
                profileService: services.profileService,
                nftService: services.nftService,
                purchasedNFTsStorage: services.purchasedNFTsStorage
            )
        case .catalog:
            CatalogTabRoot()
        case .cart:
            CartTabRoot()
        case .statistics:
            StatisticsTabRoot(
                statisticsService: services.statisticsService,
                favoritesService: services.favoritesService,
                cartService: services.cartService
            )
        }
    }

    private func isCurrentTabPushed(_ router: Router) -> Bool {
        switch router.selectedTab {
        case .profile:    !router.profilePath.isEmpty
        case .catalog:    !router.catalogPath.isEmpty
        case .cart:       !router.cartPath.isEmpty
        case .statistics: !router.statisticsPath.isEmpty
        }
    }
}

// MARK: - CatalogTabRoot

private struct CatalogTabRoot: View {

    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.catalogPath) {
            CatalogView()
                .navigationDestination(for: CatalogRoute.self) { route in
                    switch route {
                    case .collection(let collection):
                        CollectionDetailView(collection: collection)
                    case .authorWeb(let url):
                        WebViewScreen(url: url)
                    case .nftDetail(let id):
                        NftDetailView(nftId: id)
                    }
                }
        }
    }
}

// MARK: - CartTabRoot

private struct CartTabRoot: View {

    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.cartPath) {
            CartView()
                .navigationDestination(for: CartRoute.self) { route in
                    switch route {
                    case .payment:
                        PaymentView()
                    case .userAgreement(let url):
                        WebViewScreen(url: url)
                    }
                }
        }
    }
}

// MARK: - StatisticsTabRoot

private struct StatisticsTabRoot: View {

    @Environment(Router.self) private var router

    private let statisticsService: StatisticsServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let cartService: CartServiceProtocol

    init(
        statisticsService: StatisticsServiceProtocol,
        favoritesService: FavoritesServiceProtocol,
        cartService: CartServiceProtocol
    ) {
        self.statisticsService = statisticsService
        self.favoritesService = favoritesService
        self.cartService = cartService
    }

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.statisticsPath) {
            StatisticsView(
                viewModel: StatisticsViewModel(statisticsService: statisticsService)
            )
            .navigationDestination(for: StatisticsRoute.self) { route in
                switch route {
                case .userDetail(let user):
                    StatisticsUserDetailView(
                        viewModel: StatisticsUserDetailViewModel(
                            summary: user,
                            statisticsService: statisticsService
                        )
                    )
                case .userCollection(let userId, let userName):
                    StatisticsUserCollectionView(
                        viewModel: StatisticsUserCollectionViewModel(
                            userId: userId,
                            userName: userName,
                            statisticsService: statisticsService,
                            favoritesService: favoritesService,
                            cartService: cartService
                        )
                    )
                case .userWebsite(let url):
                    WebViewScreen(url: url)
                case .nftDetail(let nftId):
                    StatisticsNftDetailView(nftId: nftId)
                case ._placeholder:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - ProfileTabRoot

private struct ProfileTabRoot: View {

    // MARK: - Environment

    @Environment(Router.self) private var router

    // MARK: - State

    @State private var viewModel: ProfileViewModel

    // MARK: - Properties

    private let profileService: ProfileServiceProtocol
    private let nftService: NftServiceProtocol
    private let purchasedNFTsStorage: PurchasedNFTsStorageProtocol

    // MARK: - Initializers

    init(
        profileService: ProfileServiceProtocol,
        nftService: NftServiceProtocol,
        purchasedNFTsStorage: PurchasedNFTsStorageProtocol
    ) {
        self.profileService = profileService
        self.nftService = nftService
        self.purchasedNFTsStorage = purchasedNFTsStorage
        _viewModel = State(
            initialValue: ProfileViewModel(
                profileService: profileService,
                purchasedNFTsStorage: purchasedNFTsStorage
            )
        )
    }

    // MARK: - Body

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.profilePath) {
            ProfileView(viewModel: viewModel)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .myNfts(let nftIds):
                        MyNFTsView(
                            nftIds: nftIds,
                            nftService: nftService
                        )

                    case .favorites(let favoriteIds):
                        FavoriteNFTsView(
                            favoriteIds: favoriteIds,
                            nftService: nftService,
                            updateFavoriteIds: viewModel.updateFavoriteIds,
                            onProfileUpdated: viewModel.updateLoadedProfile
                        )

                    case .edit(let profile):
                        EditProfileView(
                            profile: profile,
                            profileService: profileService,
                            onSaved: viewModel.updateLoadedProfile
                        )

                    case .userWeb(let url):
                        WebViewScreen(url: url)
                    }
                }
        }
    }
}
