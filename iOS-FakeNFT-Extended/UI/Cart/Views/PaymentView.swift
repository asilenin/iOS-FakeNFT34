import SwiftUI

struct PaymentView: View {
    @Environment(Router.self) private var router

    private let agreementURL = URL(
        string: "https://yandex.ru/legal/practicum_termsofuse"
    )

    var body: some View {
        VStack(spacing: 0) {
            content

            Spacer()
        }
        .background(.ypWhite)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Выбор способа оплаты")
                    .font(.bold17)
                    .foregroundStyle(.ypBlack)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomPanel
        }
    }

    private var content: some View {
        VStack {
            Text("Экран валют будет реализован в Sprint 4")
                .font(.regular17)
                .foregroundStyle(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Constants.placeholderTopPadding)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: Constants.bottomPanelSpacing) {
            agreementText

            Button {
                // Оплата будет реализована в Sprint 4
            } label: {
                Text("Оплатить")
                    .font(.bold17)
                    .foregroundStyle(.ypWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.payButtonHeight)
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
            Text("Совершая покупку, вы соглашаетесь с условиями")
                .font(.regular13)
                .foregroundStyle(.ypBlack)

            Button {
                openAgreement()
            } label: {
                Text("Пользовательского соглашения")
                    .font(.regular13)
                    .foregroundStyle(.ypBlueUniversal)
            }
            .buttonStyle(.plain)
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
        static let placeholderTopPadding: CGFloat = 260

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
    }
}
