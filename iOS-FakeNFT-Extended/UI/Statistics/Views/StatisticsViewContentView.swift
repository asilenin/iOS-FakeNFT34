//
//  StatisticsViewContentView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 16.05.2026.
//

import SwiftUI

private struct StatisticsViewContent: View {
    
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
    }
    
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
            emptyView
        }
    }
    
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
                    router.push(StatisticsRoute.userPlaceholder(user), in: .statistics)
                }
                .listRowBackground(Color.ypWhite)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
