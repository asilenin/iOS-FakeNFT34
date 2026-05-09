import SwiftUI

struct TabBarView: View {

    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router

        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selection: $router.selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var content: some View {
        // TODO: each tab will be replaced with a real entry-point view
        // (CatalogView, CartView, ProfileView, StatisticsView) in the
        // next commit, wrapped in a NavigationStack bound to its
        // corresponding router path.
        switch router.selectedTab {
        case .profile:    PlaceholderTabView(tab: .profile)
        case .catalog:    PlaceholderTabView(tab: .catalog)
        case .cart:       PlaceholderTabView(tab: .cart)
        case .statistics: PlaceholderTabView(tab: .statistics)
        }
    }
}

private struct PlaceholderTabView: View {
    let tab: AppTab

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            Text("\(String(describing: tab).capitalized) – coming soon")
                .font(.bold22)
                .foregroundStyle(Color.ypBlack)
        }
    }
}
