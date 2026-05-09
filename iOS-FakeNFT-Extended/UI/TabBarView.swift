import SwiftUI

struct TabBarView: View {

    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router

        VStack(spacing: 0) {
            content(router: router)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selection: $router.selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private func content(router: Router) -> some View {
        @Bindable var router = router

        switch router.selectedTab {
        case .profile:
            NavigationStack(path: $router.profilePath) {
                ProfileView()
                    .navigationDestination(for: ProfileRoute.self) { _ in
                        // TODO(profile epic): map ProfileRoute cases
                        // to their destination views.
                        EmptyView()
                    }
            }
        case .catalog:
            NavigationStack(path: $router.catalogPath) {
                CatalogView()
                    .navigationDestination(for: CatalogRoute.self) { _ in
                        // TODO(catalog epic): map CatalogRoute cases
                        // to their destination views.
                        EmptyView()
                    }
            }
        case .cart:
            NavigationStack(path: $router.cartPath) {
                CartView()
                    .navigationDestination(for: CartRoute.self) { _ in
                        // TODO(cart epic): map CartRoute cases
                        // to their destination views.
                        EmptyView()
                    }
            }
        case .statistics:
            NavigationStack(path: $router.statisticsPath) {
                StatisticsView()
                    .navigationDestination(for: StatisticsRoute.self) { _ in
                        // TODO(statistics epic): map StatisticsRoute
                        // cases to their destination views.
                        EmptyView()
                    }
            }
        }
    }
}
