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
            case .userPlaceholder(let user):
                StatisticsUserPlaceholderView(user: user)
            case ._placeholder:
                EmptyView()
            }
        }
    }
    .environment(router)
    .environment(services)
}
