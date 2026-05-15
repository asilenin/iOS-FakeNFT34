import SwiftUI

struct CollectionDetailView: View {

    let collection: NftCollection

    @Environment(ServicesAssembly.self) private var services
    @Environment(Router.self) private var router

    @State private var viewModel: CollectionDetailViewModel?

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.pop(in: .catalog)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.ypBlack)
                }
            }
        }
        .errorAlert(error: errorBinding) {
            Task { await viewModel?.load() }
        }
        .task {
            if viewModel == nil {
                viewModel = CollectionDetailViewModel(
                    collection: collection,
                    service: services.collectionDetailService
                )
            }
            await viewModel?.load()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            switch viewModel.state {
            case .loading:
                LoadingSpinner(size: .medium)
            case .success:
                successContent(viewModel)
            case .error:
                ScrollView {
                    CatalogEmptyStateView(message: "Catalog.loadErrorHint")
                        .frame(minHeight: 400)
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        } else {
            LoadingSpinner(size: .medium)
        }
    }

    private func successContent(_ viewModel: CollectionDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CollectionHeader(collection: collection) {
                    handleAuthorTap(viewModel)
                }

                grid(viewModel)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
            }
        }
        .refreshable {
            await viewModel.load()
        }
        .ignoresSafeArea(.container, edges: .top)
    }

    private func grid(_ viewModel: CollectionDetailViewModel) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 9),
                GridItem(.flexible(), spacing: 9),
                GridItem(.flexible(), spacing: 0)
            ],
            spacing: 8
        ) {
            ForEach(viewModel.nfts) { nft in
                NftGridCell(
                    configuration: NftGridCellConfiguration(
                        nft: nft,
                        isFavorite: viewModel.favoriteIds.contains(nft.id),
                        isInCart: viewModel.cartIds.contains(nft.id)
                    ),
                    actions: NftGridCellActions(
                        onFavoriteTap: { viewModel.toggleFavorite(nft.id) },
                        onCartTap: { viewModel.toggleCart(nft.id) },
                        onCellTap: { router.push(CatalogRoute.nftDetail(nft.id), in: .catalog) }
                    )
                )
            }
        }
    }

    // MARK: - Actions

    private func handleAuthorTap(_ viewModel: CollectionDetailViewModel) {
        let websiteString = viewModel.author?.website ?? collection.website?.absoluteString
        guard
            let websiteString,
            let url = URL(string: websiteString)
        else {
            return
        }
        router.push(CatalogRoute.authorWeb(url), in: .catalog)
    }

    // MARK: - Bindings

    private var errorBinding: Binding<Error?> {
        Binding(
            get: { viewModel?.error },
            set: { viewModel?.error = $0 }
        )
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(collection: MockCatalogService.mockCollections[0])
            .environment(ServicesAssembly(networkClient: DefaultNetworkClient()))
            .environment(Router())
    }
}
