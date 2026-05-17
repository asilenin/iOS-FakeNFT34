import SwiftUI

struct TabBarView: View {

    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var services

    var body: some View {
        @Bindable var router = router

        VStack(spacing: 0) {
            content(router: router)
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
    private func content(router: Router) -> some View {
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
                    .navigationDestination(for: CatalogRoute.self) { _ in
                        EmptyView()
                    }
            }
        case .cart:
            NavigationStack(path: $router.cartPath) {
                CartView()
                    .navigationDestination(for: CartRoute.self) { _ in
                        EmptyView()
                    }
            }
        case .statistics:
            NavigationStack(path: $router.statisticsPath) {
                StatisticsView(
                    viewModel: StatisticsViewModel(
                        statisticsService: services.statisticsService
                    )
                )
                .navigationDestination(for: StatisticsRoute.self) { route in
                    statisticsDestination(for: route)
                }
            }
        }
    }

    @ViewBuilder
    private func statisticsDestination(for route: StatisticsRoute) -> some View {
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
                    statisticsService: services.statisticsService
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

    private func isCurrentTabPushed(_ router: Router) -> Bool {
        switch router.selectedTab {
        case .profile: !router.profilePath.isEmpty
        case .catalog: !router.catalogPath.isEmpty
        case .cart: !router.cartPath.isEmpty
        case .statistics: !router.statisticsPath.isEmpty
        }
    }
}
