//
//  StatisticsViewContentView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 16.05.2026.
//

import SwiftUI

struct StatisticsViewContentView: View {

    @Environment(Router.self) private var router
    @Bindable var viewModel: StatisticsViewModel

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .navigationTitle(Text("Tab.statistics"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { sortToolbar }
        .errorAlert(error: $viewModel.loadError) {
            Task { await viewModel.load() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .empty:
            emptyView
        case .success:
            statisticsList
        case .error:
            Color.clear
        }
    }

    // MARK: - Private Views

    private var loadingView: some View {
        LoadingSpinner(size: .large)
    }

    private var emptyView: some View {
        Text("Statistics.empty")
            .font(.regular17)
            .foregroundStyle(Color.ypGrayUniversal)
            .multilineTextAlignment(.center)
            .padding()
    }

    private var statisticsList: some View {
        List {
            ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                StatisticsRowView(rank: index + 1, user: user) {
                    router.push(StatisticsRoute.userDetail(user), in: .statistics)
                }
                .listRowBackground(Color.ypWhite)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ToolbarContentBuilder
    private var sortToolbar: some ToolbarContent {
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
}
