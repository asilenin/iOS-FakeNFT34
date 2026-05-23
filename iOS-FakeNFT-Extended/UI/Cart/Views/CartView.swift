import SwiftUI

struct CartView: View {
    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var services

    @State private var viewModel = CartViewModel()
    @State private var itemPendingDeletion: CartItem?
    @State private var isSortDialogPresented = false

    @AppStorage(Constants.sortOptionStorageKey) private var storedSortOption: CartSortOption = .name
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
                        MenuButton {
                            isSortDialogPresented = true
                        }
                    }
                }
            }
            .confirmationDialog(
                Text(Strings.sortTitle),
                isPresented: $isSortDialogPresented,
                titleVisibility: .visible
            ) {
                Button(Strings.sortByPrice) {
                    storedSortOption = .price
                }

                Button(Strings.sortByRating) {
                    storedSortOption = .rating
                }

                Button(Strings.sortByName) {
                    storedSortOption = .name
                }

                Button(Strings.close, role: .cancel) { }
            }
            .fullScreenCover(item: $itemPendingDeletion) { item in
                deleteConfirmation(for: item)
                    .presentationBackground(.ultraThinMaterial)
            }
            .task {
                viewModel.sortOption = storedSortOption
                await viewModel.loadIfNeeded(service: services.cartService)
            }
            .onChange(of: storedSortOption) { _, newValue in
                viewModel.sortOption = newValue
            }
            .onChange(of: router.cartPath.count) { _, newValue in
                guard newValue == 0 else { return }

                Task {
                    await viewModel.load(service: services.cartService)
                }
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

    private var mainContent: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if viewModel.state == .loaded {
                bottomPanel
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingSpinner(size: .medium)

        case .loaded:
            cartList

        case .empty:
            emptyView

        case .success:
            EmptyView()

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
        Text(Strings.emptyCart)
            .font(.bold17)
            .foregroundStyle(.ypBlack)
    }

    private var emptyErrorView: some View {
        VStack(spacing: Constants.errorSpacing) {
            Text(Strings.loadingError)
                .font(.bold17)
                .foregroundStyle(.ypBlack)

            Button(Strings.retry) {
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
                Text(Strings.pay)
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
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.bottomHorizontalPadding)
        .padding(.vertical, Constants.bottomVerticalPadding)
        .frame(height: Constants.bottomPanelHeight)
        .background {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: Constants.bottomPanelCornerRadius,
                    topTrailing: Constants.bottomPanelCornerRadius
                )
            )
            .fill(.ypGrayLight)
        }
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
    enum Strings {
        static let sortTitle = "Сортировка"
        static let sortByPrice = "По цене"
        static let sortByRating = "По рейтингу"
        static let sortByName = "По названию"
        static let close = "Закрыть"
        static let emptyCart = "Корзина пуста"
        static let loadingError = "Не удалось загрузить корзину"
        static let retry = "Повторить"
        static let pay = "К оплате"
    }

    enum Constants {
        static let sortOptionStorageKey = "cart.sort.option"
        static let horizontalPadding: CGFloat = 16

        static let errorSpacing: CGFloat = 12

        static let loaderBackgroundOpacity: CGFloat = 0.12
        static let deleteConfirmationHorizontalPadding: CGFloat = 62

        static let bottomPanelSpacing: CGFloat = 16
        static let bottomTextSpacing: CGFloat = 2

        static let bottomHorizontalPadding: CGFloat = 16
        static let bottomVerticalPadding: CGFloat = 16

        static let bottomPanelHeight: CGFloat = 76
        static let bottomPanelCornerRadius: CGFloat = 12

        static let payButtonWidth: CGFloat = 240
        static let payButtonHeight: CGFloat = 44
        static let payButtonCornerRadius: CGFloat = 16
    }
}

#Preview("Cart") {
    NavigationStack {
        CartView()
            .environment(Router())
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
    }
}
