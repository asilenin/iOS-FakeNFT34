import SwiftUI

struct CollectionDetailView: View {

    let collection: NftCollection

    @Environment(ServicesAssembly.self) private var services
    @Environment(Router.self) private var router

    @State private var viewModel: CollectionDetailViewModel?

    init(collection: NftCollection) {
        self.collection = collection
    }

    /// Designated initializer for Preview. Provides a pre-built ViewModel so the
    /// `.task` block reuses it instead of creating one through `ServicesAssembly`.
    /// Keeps SwiftUI Previews offline.
    fileprivate init(collection: NftCollection, previewViewModel: CollectionDetailViewModel) {
        self.collection = collection
        _viewModel = State(wrappedValue: previewViewModel)
    }

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
            Task { await viewModel?.reload() }
        }
        .favoritesErrorAlert(viewModel: viewModel)
        .cartErrorAlert(viewModel: viewModel)
        .task {
            if viewModel == nil {
                viewModel = CollectionDetailViewModel(
                    collection: collection,
                    service: services.collectionDetailService,
                    favoritesService: services.catalogFavoritesService,
                    cartService: services.catalogCartService
                )
            }
            await viewModel?.reload()
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
                        isFavorite: viewModel.isFavorite(nft.id),
                        isInCart: viewModel.isInCart(nft.id),
                        isFavoriteDisabled:
                            viewModel.favoritesDisabled || viewModel.isFavoritePending(nft.id),
                        isCartDisabled:
                            viewModel.cartDisabled || viewModel.isCartPending(nft.id)
                    ),
                    actions: NftGridCellActions(
                        onFavoriteTap: { Task { await viewModel.didTapFavorite(nft.id) } },
                        onCartTap: { Task { await viewModel.didTapCart(nft.id) } },
                        onCellTap: { router.push(CatalogRoute.nftDetail(nft.id), in: .catalog) }
                    )
                )
            }
        }
    }

    // MARK: - Actions

    private func handleAuthorTap(_ viewModel: CollectionDetailViewModel) {
        guard let url = viewModel.authorURL else { return }
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

// MARK: - Favorites error alert

private extension View {
    /// Алерт ошибки лайков. Две кнопки:
    /// - "Повторить" → `retryLoadFavorites()` (повторно грузит лайки).
    /// - "Отмена" → `disableFavorites()` (дизейблит кнопки сердец до reload).
    ///
    /// Не использует общий `errorAlert`-modifier, потому что у того кнопка
    /// "Отмена" просто закрывает алерт без дополнительного действия.
    func favoritesErrorAlert(viewModel: CollectionDetailViewModel?) -> some View {
        alert(
            Text("Error.title"),
            isPresented: Binding(
                get: { viewModel?.favoritesError != nil },
                set: { newValue in
                    if !newValue { viewModel?.favoritesError = nil }
                }
            ),
            presenting: viewModel?.favoritesError
        ) { _ in
            Button(role: .cancel) {
                viewModel?.disableFavorites()
            } label: {
                Text("Error.cancel")
            }
            Button {
                Task { await viewModel?.retryLoadFavorites() }
            } label: {
                Text("Error.retry")
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    /// Алерт ошибки корзины. Две кнопки:
    /// - "Повторить" → `retryLoadCart()` (повторно грузит корзину).
    /// - "Отмена" → `disableCart()` (дизейблит кнопки корзины до reload).
    func cartErrorAlert(viewModel: CollectionDetailViewModel?) -> some View {
        alert(
            Text("Error.title"),
            isPresented: Binding(
                get: { viewModel?.cartError != nil },
                set: { newValue in
                    if !newValue { viewModel?.cartError = nil }
                }
            ),
            presenting: viewModel?.cartError
        ) { _ in
            Button(role: .cancel) {
                viewModel?.disableCart()
            } label: {
                Text("Error.cancel")
            }
            Button {
                Task { await viewModel?.retryLoadCart() }
            } label: {
                Text("Error.retry")
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

#Preview {
    let collection = MockCatalogService.mockCollections[0]
    NavigationStack {
        CollectionDetailView(
            collection: collection,
            previewViewModel: CollectionDetailViewModel(
                collection: collection,
                service: MockCollectionDetailService(),
                favoritesService: MockCatalogFavoritesService(),
                cartService: MockCatalogCartService()
            )
        )
        // ServicesAssembly is still required by @Environment, but its services
        // are not accessed because the ViewModel is pre-built above.
        .environment(ServicesAssembly(networkClient: DefaultNetworkClient()))
        .environment(Router())
    }
}
