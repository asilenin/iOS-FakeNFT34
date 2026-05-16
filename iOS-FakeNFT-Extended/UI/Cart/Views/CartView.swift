import SwiftUI

struct CartView: View {
    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var services
    @State private var viewModel: CartViewModel
    @State private var itemPendingDeletion: CartItem?
    @State private var isSortDialogPresented = false

    private let useMockData: Bool

    @MainActor
    init(useMockData: Bool = false) {
        self.useMockData = useMockData
        _viewModel = State(initialValue: CartViewModel())
    }

    @MainActor
    init(
        viewModel: CartViewModel,
        useMockData: Bool = false
    ) {
        self.useMockData = useMockData
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        mainContent
            .overlay {
                if viewModel.isDeleting {
                    Color.ypBlack.opacity(Constants.loaderBackgroundOpacity)
                        .ignoresSafeArea()

                    LoadingSpinner(size: .medium)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if shouldShowSortButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortButton
                    }
                }
            }
            .fullScreenCover(isPresented: $isSortDialogPresented) {
                sortSheet
                    .presentationBackground(.clear)
            }
            .fullScreenCover(item: $itemPendingDeletion) { item in
                deleteConfirmation(for: item)
                    .presentationBackground(.ultraThinMaterial)
            }
            .task {
                #if DEBUG
                if useMockData {
                    viewModel.loadMock()
                    return
                }
                #endif

                await viewModel.loadIfNeeded(service: services.cartService)
            }
            .errorAlert(error: $viewModel.error) {
                Task {
                    await viewModel.retryLastDelete(service: services.cartService)
                }
            }
    }

    private var shouldShowSortButton: Bool {
        viewModel.state == .loaded
            && itemPendingDeletion == nil
            && !viewModel.isDeleting
    }

    private var sortButton: some View {
        Button {
            isSortDialogPresented = true
        } label: {
            Image(.menu)
                .renderingMode(.template)
                .foregroundStyle(.ypBlack)
                .frame(
                    width: Constants.sortButtonTapSize,
                    height: Constants.sortButtonTapSize
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Сортировка"))
    }

    private var sortSheet: some View {
        ZStack(alignment: .bottom) {
            Color.ypBlack
                .opacity(Constants.sortOverlayOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    isSortDialogPresented = false
                }

            VStack(spacing: Constants.sortCancelTopSpacing) {
                VStack(spacing: 0) {
                    Text("Сортировка")
                        .font(.regular17)
                        .foregroundStyle(.ypBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.sortTitleHeight)

                    Divider()

                    sortOptionButton("По цене", option: .price)

                    Divider()

                    sortOptionButton("По рейтингу", option: .rating)

                    Divider()

                    sortOptionButton("По названию", option: .name)
                }
                .background(.ypWhite)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: Constants.sortSheetCornerRadius
                    )
                )

                Button {
                    isSortDialogPresented = false
                } label: {
                    Text("Закрыть")
                        .font(.bold17)
                        .foregroundStyle(.ypBlueUniversal)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.sortButtonHeight)
                        .background(.ypWhite)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: Constants.sortSheetCornerRadius
                            )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Constants.sortSheetHorizontalPadding)
            .padding(.bottom, Constants.sortSheetBottomPadding)
        }
        .ignoresSafeArea()
    }

    private func sortOptionButton(
        _ title: String,
        option: CartSortOption
    ) -> some View {
        Button {
            viewModel.sortOption = option
            isSortDialogPresented = false
        } label: {
            Text(title)
                .font(.regular17)
                .foregroundStyle(.ypBlueUniversal)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.sortButtonHeight)
        }
        .buttonStyle(.plain)
    }

    private var mainContent: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.state == .loaded {
                bottomPanel
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingSpinner(size: .large)

        case .loaded:
            cartList

        case .empty:
            emptyView

        case .error:
            emptyErrorView
        }
    }

    private var cartList: some View {
        List(viewModel.items) { item in
            CartItemView(item: item) {
                itemPendingDeletion = item
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, Constants.horizontalPadding)
    }

    private var emptyView: some View {
        Text("Корзина пуста")
            .font(.bold17)
            .foregroundStyle(.ypBlack)
    }

    private var emptyErrorView: some View {
        VStack(spacing: Constants.errorSpacing) {
            Text("Не удалось загрузить корзину")
                .font(.bold17)
                .foregroundStyle(.ypBlack)

            Button("Повторить") {
                Task {
                    await viewModel.load(service: services.cartService)
                }
            }
            .font(.regular17)
            .foregroundStyle(.ypBlueUniversal)
        }
    }

    private var bottomPanel: some View {
        HStack(spacing: Constants.bottomPanelSpacing) {
            VStack(alignment: .leading, spacing: Constants.bottomTextSpacing) {
                Text(viewModel.totalCountText)
                    .font(.regular15)
                    .foregroundStyle(.ypBlack)

                Text(viewModel.totalPriceText)
                    .font(.bold17)
                    .foregroundStyle(.ypGreenUniversal)
            }

            Spacer()

            Button {
                router.push(CartRoute.payment, in: .cart)
            } label: {
                Text("К оплате")
                    .font(.bold17)
                    .foregroundStyle(.ypWhite)
                    .frame(
                        width: Constants.payButtonWidth,
                        height: Constants.payButtonHeight
                    )
                    .background(.ypBlack)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: Constants.payButtonCornerRadius
                        )
                    )
            }
        }
        .padding(.horizontal, Constants.bottomHorizontalPadding)
        .padding(.vertical, Constants.bottomVerticalPadding)
        .frame(height: Constants.bottomPanelHeight)
        .background(.ypGrayLight)
    }

    private func deleteConfirmation(for item: CartItem) -> some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .onTapGesture {
                    itemPendingDeletion = nil
                }

            DeleteCartItemConfirmationView(
                item: item,
                onDelete: {
                    itemPendingDeletion = nil
                    Task {
                        await viewModel.delete(item, service: services.cartService)
                    }
                },
                onCancel: {
                    itemPendingDeletion = nil
                }
            )
            .padding(.horizontal, Constants.deleteConfirmationHorizontalPadding)
        }
        .ignoresSafeArea()
    }
}

private extension CartView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16

        static let sortButtonTapSize: CGFloat = 44
        static let sortOverlayOpacity: CGFloat = 0.35
        static let sortSheetHorizontalPadding: CGFloat = 8
        static let sortSheetBottomPadding: CGFloat = 34
        static let sortSheetCornerRadius: CGFloat = 13
        static let sortTitleHeight: CGFloat = 48
        static let sortButtonHeight: CGFloat = 66
        static let sortCancelTopSpacing: CGFloat = 8

        static let errorSpacing: CGFloat = 12

        static let loaderBackgroundOpacity: CGFloat = 0.12
        static let deleteConfirmationHorizontalPadding: CGFloat = 62

        static let bottomPanelSpacing: CGFloat = 16
        static let bottomTextSpacing: CGFloat = 2

        static let bottomHorizontalPadding: CGFloat = 16
        static let bottomVerticalPadding: CGFloat = 16

        static let bottomPanelHeight: CGFloat = 76

        static let payButtonWidth: CGFloat = 240
        static let payButtonHeight: CGFloat = 44
        static let payButtonCornerRadius: CGFloat = 16
    }
}

#Preview("Cart - Loaded") {
    NavigationStack {
        CartView(viewModel: .previewLoaded())
            .environment(Router())
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
    }
}

#Preview("Cart - Empty") {
    NavigationStack {
        CartView(viewModel: .previewEmpty())
            .environment(Router())
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
    }
}

#Preview("Cart - Loading") {
    NavigationStack {
        CartView(viewModel: .previewLoading())
            .environment(Router())
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
    }
}

#Preview("Cart - Error") {
    NavigationStack {
        CartView(viewModel: .previewError())
            .environment(Router())
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
    }
}
