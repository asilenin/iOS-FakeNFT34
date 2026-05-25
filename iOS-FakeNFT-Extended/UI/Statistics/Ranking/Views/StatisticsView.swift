import SwiftUI

struct StatisticsView: View {

    @Environment(Router.self) private var router
    @State private var viewModel: StatisticsViewModel

    init(viewModel: StatisticsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        StatisticsViewContentView(viewModel: viewModel)
            .environment(router)
            .task { await viewModel.load() }
    }
}

#Preview {
    @Previewable @State var router = Router()
    let services = ServicesAssembly(networkClient: DefaultNetworkClient())

    NavigationStack(path: $router.statisticsPath) {
        StatisticsView(
            viewModel: StatisticsViewModel(
                statisticsService: services.statisticsService
            )
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
        }
    }
    .environment(router)
    .environment(services)
}
