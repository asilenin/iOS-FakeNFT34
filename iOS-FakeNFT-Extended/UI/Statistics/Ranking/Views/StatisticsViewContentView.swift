//
//  StatisticsViewContentView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 16.05.2026.
//

import SwiftUI

struct StatisticsViewContentView: View {

    // MARK: - Properties

    @Environment(Router.self) private var router
    @Bindable var viewModel: StatisticsViewModel

    @State private var isShowingSortDialog = false

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .navigationTitle(Text("Tab.statistics"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                MenuButton { isShowingSortDialog = true }
            }
        }
        .confirmationDialog(
            Text("Statistics.sort.title"),
            isPresented: $isShowingSortDialog,
            titleVisibility: .visible
        ) {
            Button("Statistics.sort.byName") {
                viewModel.setSortOption(.byName)
            }
            Button("Statistics.sort.byRating") {
                viewModel.setSortOption(.byRating)
            }
            Button("Statistics.sort.byNftsCount") {
                viewModel.setSortOption(.byNftsCount)
            }
            Button("Common.close", role: .cancel) {}
        }
        .errorAlert(error: $viewModel.loadError) {
            Task { await viewModel.load() }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingSpinner(size: .medium)
        case .empty:
            StatisticsEmptyStateView(message: "Statistics.empty")
        case .success:
            statisticsList
        case .error:
            StatisticsEmptyStateView(message: "Statistics.loadErrorHint")
        }
    }

    private var statisticsList: some View {
        List {
            ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                StatisticsRowView(rank: index + 1, user: user) {
                    router.push(StatisticsRoute.userDetail(user), in: .statistics)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.ypWhite)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 20, for: .scrollContent)
    }
}

#Preview {
    @Previewable @State var router = Router()
    let services = ServicesAssembly(networkClient: DefaultNetworkClient())

    NavigationStack(path: $router.statisticsPath) {
        StatisticsViewContentView(
            viewModel: StatisticsViewModel(
                statisticsService: services.statisticsService
            )
        )
        .environment(router)
    }
    .environment(services)
}
