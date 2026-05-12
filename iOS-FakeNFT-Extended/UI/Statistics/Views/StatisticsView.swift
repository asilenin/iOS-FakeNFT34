import SwiftUI

struct StatisticsView: View {

    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var services

    @State private var viewModel: StatisticsViewModel?

    var body: some View {
        Group {
            if let viewModel {
                StatisticsViewContent(viewModel: viewModel)
                    .environment(router)
            } else {
                Color.ypWhite
                    .ignoresSafeArea()
                    .task {
                        if viewModel == nil {
                            viewModel = StatisticsViewModel(statisticsService: services.statisticsService)
                        }
                    }
            }
        }
    }
}

// MARK: - Content

private struct StatisticsViewContent: View {

    @Environment(Router.self) private var router
    @Bindable var viewModel: StatisticsViewModel

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            if viewModel.isLoading && viewModel.users.isEmpty {
                LoadingSpinner(size: .large)
            } else if !viewModel.isLoading && viewModel.users.isEmpty && viewModel.loadError == nil {
                Text("Statistics.empty")
                    .font(.regular17)
                    .foregroundStyle(Color.ypGrayUniversal)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List {
                    ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                        StatisticsRow(rank: index + 1, user: user) {
                            router.push(StatisticsRoute.userPlaceholder(user), in: .statistics)
                        }
                        .listRowBackground(Color.ypWhite)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(Text("Tab.statistics"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(StatisticsSortOption.allCases) { option in
                        Button {
                            viewModel.setSortOption(option)
                        } label: {
                            HStack {
                                Text(option.localizedTitle)
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(.menu)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .foregroundStyle(Color.ypBlack)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text("Common.sort"))
            }
        }
        .task {
            await viewModel.load()
        }
        .errorAlert(error: $viewModel.loadError) {
            Task { await viewModel.load() }
        }
    }
}

#Preview {
    @Previewable @State var router = Router()
    let services = ServicesAssembly(networkClient: DefaultNetworkClient())

    NavigationStack(path: $router.statisticsPath) {
        StatisticsView()
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
