import SwiftUI

struct CartView: View {
    @Environment(ServicesAssembly.self) private var services
    @State private var viewModel: CartViewModel

    @MainActor
    init() {
        _viewModel = State(initialValue: CartViewModel())
    }

    @MainActor
    init(viewModel: CartViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.ypWhite.ignoresSafeArea()

            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if viewModel.state == .loaded {
                bottomPanel
            }
        }
        .task {
            #if DEBUG
            if viewModel.state == .idle {
                viewModel.loadMock()
            }
            #else
            await viewModel.loadIfNeeded(service: services.cartService)
            #endif
        }
        .errorAlert(error: $viewModel.error) {
            Task {
                await viewModel.load(service: services.cartService)
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
                // Sprint 3: show delete confirmation and update order through PUT.
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
                // Sprint 3: push payment screen through CartRoute.
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
}

private extension CartView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16

        static let errorSpacing: CGFloat = 12

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
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
    }
}

#Preview("Cart - Dark") {
    NavigationStack {
        CartView(viewModel: .previewLoaded())
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
            .preferredColorScheme(.dark)
    }
}

#Preview("CartView with TabBar") {
    TabBarView()
        .environment(Router())
        .environment(
            ServicesAssembly(
                networkClient: DefaultNetworkClient()
            )
        )
}
