import SwiftUI

struct TabBarView: View {

    @Environment(Router.self) private var router

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
                        // TODO(profile epic): map ProfileRoute cases to their destination views.
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
                        }
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
