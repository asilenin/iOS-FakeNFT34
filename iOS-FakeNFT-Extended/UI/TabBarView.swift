import SwiftUI

struct TabBarView: View {

    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var servicesAssembly

    var body: some View {
        @Bindable var router = router

        VStack(spacing: 0) {
            content(router: router)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isCurrentTabPushed(router) {
                CustomTabBar(selection: $router.selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private func content(router: Router) -> some View {
        @Bindable var router = router

        switch router.selectedTab {
        case .profile:
            ProfileTabRoot(
                profileService: servicesAssembly.profileService,
                nftService: servicesAssembly.nftService
            )
        case .catalog:
            NavigationStack(path: $router.catalogPath) {
                CatalogView()
                    .navigationDestination(for: CatalogRoute.self) { _ in
                        // TODO(catalog epic): map CatalogRoute cases to their destination views.
                        EmptyView()
                    }
            }
        case .cart:
            NavigationStack(path: $router.cartPath) {
                CartView()
                    .navigationDestination(for: CartRoute.self) { _ in
                        // TODO(cart epic): map CartRoute cases to their destination views.
                        EmptyView()
                    }
            }
        case .statistics:
            NavigationStack(path: $router.statisticsPath) {
                StatisticsView()
                    .navigationDestination(for: StatisticsRoute.self) { _ in
                        // TODO(statistics epic): map StatisticsRoute cases to their destination views.
                        EmptyView()
                    }
            }
        }
    }

    /// True when the currently selected tab has any pushed screens.
    private func isCurrentTabPushed(_ router: Router) -> Bool {
        switch router.selectedTab {
        case .profile:    !router.profilePath.isEmpty
        case .catalog:    !router.catalogPath.isEmpty
        case .cart:       !router.cartPath.isEmpty
        case .statistics: !router.statisticsPath.isEmpty
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

    // MARK: - Initializers

    init(
        profileService: ProfileServiceProtocol,
        nftService: NftServiceProtocol
    ) {
        self.profileService = profileService
        self.nftService = nftService
        _viewModel = State(initialValue: ProfileViewModel(profileService: profileService))
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
