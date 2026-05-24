//
//  StatisticsUserCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import SwiftUI

struct StatisticsUserCollectionView: View {

    // MARK: - Properties

    @Environment(Router.self) private var router
    @State private var viewModel: StatisticsUserCollectionViewModel

    init(viewModel: StatisticsUserCollectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .navigationTitle(Text("Statistics.collection.title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.pop(in: .statistics)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.ypBlack)
                }
            }
        }
        .task { await viewModel.load() }
        .errorAlert(error: $viewModel.loadError) {
            Task { await viewModel.load() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingSpinner(size: .medium)
        case .empty:
            StatisticsEmptyStateView(message: "Statistics.collection.empty")
        case .success:
            collectionGrid
        case .error:
            StatisticsEmptyStateView(message: "Statistics.collection.loadErrorHint")
        }
    }

    private var collectionGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 9),
                    GridItem(.flexible(), spacing: 9),
                    GridItem(.flexible(), spacing: 0)
                ],
                spacing: 8
            ) {
                ForEach(viewModel.nfts) { nft in
                    StatisticsNftGridCellView(
                        configuration: StatisticsNftGridCellConfiguration(
                            nft: nft,
                            isFavorite: viewModel.isFavorite(nft.id),
                            isInCart: viewModel.isInCart(nft.id)
                        ),
                        actions: StatisticsNftGridCellActions(
                            onFavoriteTap: { viewModel.didTapFavorite(nft.id) },
                            onCartTap: { viewModel.didTapCart(nft.id) },
                            onCellTap: {
                                router.push(StatisticsRoute.nftDetail(nft.id), in: .statistics)
                            }
                        )
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
        .refreshable {
            await viewModel.load()
        }
    }
}

#Preview {
    @Previewable @State var router = Router()
    let services = ServicesAssembly(networkClient: DefaultNetworkClient())

    NavigationStack(path: $router.statisticsPath) {
        StatisticsUserCollectionView(
            viewModel: StatisticsUserCollectionViewModel(
                userId: "1",
                userName: "Alice",
                statisticsService: services.statisticsService,
                favoritesService: services.favoritesService,
                cartService: services.cartService
            )
        )
    }
    .environment(router)
    .environment(services)
}
