import SwiftUI

struct PaymentView: View {
    @Environment(Router.self) private var router
    @Environment(ServicesAssembly.self) private var services
    
    @State private var viewModel = PaymentViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 7),
        GridItem(.flexible(), spacing: 7)
    ]
    
    private let agreementURL = URL(
        string: "https://yandex.ru/legal/practicum_termsofuse"
    )
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        content
            .background(.ypWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "Cart.Payment.title"))
                        .font(.bold17)
                        .foregroundStyle(.ypBlack)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if viewModel.state != .success {
                    bottomPanel
                }
            }
            .overlay {
                if viewModel.isPaying {
                    Color.ypBlack.opacity(Constants.loaderBackgroundOpacity)
                        .ignoresSafeArea()
                    
                    LoadingSpinner(size: .medium)
                }
            }
            .task {
                await viewModel.loadIfNeeded(service: services.paymentService)
            }
            .alert(
                String(localized: "Cart.Payment.error.pay"),
                isPresented: paymentErrorBinding
            ) {
                Button(String(localized: "Error.cancel"), role: .cancel) {
                    viewModel.error = nil
                }
                
                Button(String(localized: "Error.retry")) {
                    Task {
                        await viewModel.retryPayment(
                            paymentService: services.paymentService,
                            cartService: services.cartService,
                            profileService: services.profileService
                        )
                    }
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingSpinner(size: .medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .loaded:
            currenciesGrid
            
        case .success:
            PaymentSuccessView {
                router.popToRoot(in: .cart)
            }
            
        case .empty:
            EmptyView()
            
        case .error:
            errorView
        }
    }
    
    private var currenciesGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Constants.gridSpacing) {
                ForEach(viewModel.currencies) { currency in
                    PaymentCurrencyCellView(
                        currency: currency,
                        isSelected: viewModel.selectedCurrency == currency
                    ) {
                        viewModel.select(currency)
                    }
                }
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.gridTopPadding)
            .padding(.bottom, Constants.gridBottomPadding)
        }
    }
    
    private var errorView: some View {
        VStack(spacing: Constants.errorSpacing) {
            Text(String(localized: "Cart.Payment.error.load"))
                .font(.bold17)
                .foregroundStyle(.ypBlack)
            
            Button(String(localized: "Error.retry")) {
                Task {
                    await viewModel.load(service: services.paymentService)
                }
            }
            .font(.regular17)
            .foregroundStyle(.ypBlueUniversal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: Constants.bottomPanelSpacing) {
            agreementText
            
            Button {
                Task {
                    await viewModel.pay(
                        paymentService: services.paymentService,
                        cartService: services.cartService,
                        profileService: services.profileService
                    )
                }
            } label: {
                Text(String(localized: "Cart.Payment.pay"))
                    .font(.bold17)
                    .foregroundStyle(.ypWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.payButtonHeight)
                    .background(payButtonBackground)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: Constants.payButtonCornerRadius
                        )
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canPay)
        }
        .padding(.horizontal, Constants.bottomHorizontalPadding)
        .padding(.top, Constants.bottomTopPadding)
        .padding(.bottom, Constants.bottomBottomPadding)
        .background {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: Constants.bottomPanelCornerRadius,
                    topTrailing: Constants.bottomPanelCornerRadius
                )
            )
            .fill(.ypGrayLight)
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private var agreementText: some View {
        VStack(alignment: .leading, spacing: Constants.agreementSpacing) {
            Text(String(localized: "Cart.Payment.agreement.prefix"))
                .font(.regular13)
                .foregroundStyle(.ypBlack)
            
            Button {
                openAgreement()
            } label: {
                Text(String(localized: "Cart.Payment.agreement.link"))
                    .font(.regular13)
                    .foregroundStyle(.ypBlueUniversal)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var payButtonBackground: Color {
        viewModel.canPay ? .ypBlack : .ypGrayUniversal
    }
    
    private var paymentErrorBinding: Binding<Bool> {
        Binding {
            viewModel.error != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.error = nil
            }
        }
    }
    
    private func openAgreement() {
        guard let agreementURL else { return }
        
        router.push(
            CartRoute.userAgreement(agreementURL),
            in: .cart
        )
    }
}

private extension PaymentView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let gridSpacing: CGFloat = 7
        static let gridTopPadding: CGFloat = 20
        static let gridBottomPadding: CGFloat = 176
        
        static let errorSpacing: CGFloat = 12
        static let loaderBackgroundOpacity: CGFloat = 0.12
        
        static let bottomHorizontalPadding: CGFloat = 16
        static let bottomTopPadding: CGFloat = 16
        static let bottomBottomPadding: CGFloat = 34
        static let bottomPanelSpacing: CGFloat = 16
        static let bottomPanelCornerRadius: CGFloat = 12
        
        static let agreementSpacing: CGFloat = 4
        
        static let payButtonHeight: CGFloat = 60
        static let payButtonCornerRadius: CGFloat = 16
    }
}

#Preview {
    NavigationStack {
        PaymentView()
            .environment(Router())
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient()
                )
            )
    }
}
