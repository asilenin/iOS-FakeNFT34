import SwiftUI

struct TabBarView: View {

    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var services

    var body: some View {
        @Bindable var router = router

        VStack(spacing: 0) {
            content(router: router, services: services)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isCurrentTabPushed(router) {
                CustomTabBar(selection: $router.selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(.easeInOut(duration: 0.2), value: isCurrentTabPushed(router))
    }

    @ViewBuilder
    private func content(router: Router, services: ServicesAssembly) -> some View {
        @Bindable var router = router

        switch router.selectedTab {
        case .profile:
            NavigationStack(path: $router.profilePath) {
                ProfileView()
                    .navigationDestination(for: ProfileRoute.self) { _ in
                        EmptyView()
                    }
            }
        case .catalog:
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
        case .cart:
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
        case .statistics:
            NavigationStack(path: $router.statisticsPath) {
                StatisticsView(
                    viewModel: StatisticsViewModel(statisticsService: services.statisticsService)
                )
                .navigationDestination(for: StatisticsRoute.self) { route in
                    switch route {
                    case .userDetail(let user):
                        StatisticsUserDetailView(
                            viewModel: StatisticsUserDetailViewModel(
                                summary: user,
                                statisticsService: services.statisticsService
                            )
                        )
                    case .userCollection(let userId, let userName):
                        StatisticsUserCollectionView(
                            viewModel: StatisticsUserCollectionViewModel(
                                userId: userId,
                                userName: userName,
                                statisticsService: services.statisticsService,
                                favoritesService: services.favoritesService,
                                cartService: services.cartService
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

    private func isCurrentTabPushed(_ router: Router) -> Bool {
        switch router.selectedTab {
        case .profile:    !router.profilePath.isEmpty
        case .catalog:    !router.catalogPath.isEmpty
        case .cart:       !router.cartPath.isEmpty
        case .statistics: !router.statisticsPath.isEmpty
        }
    }
}
