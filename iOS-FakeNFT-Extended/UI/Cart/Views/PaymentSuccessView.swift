import SwiftUI

struct PaymentSuccessView: View {
    let onReturnToCart: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            Spacer()

            VStack(spacing: Constants.contentSpacing) {
                Image(.success)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: Constants.imageSize,
                        height: Constants.imageSize
                    )

                Text(Constants.title)
                    .font(.bold22)
                    .foregroundStyle(.ypBlack)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Constants.horizontalPadding)

            Spacer()

            Button(action: onReturnToCart) {
                Text(Constants.buttonTitle)
                    .font(.bold17)
                    .foregroundStyle(.ypWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.buttonHeight)
                    .background(.ypBlack)
                    .clipShape(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                    )
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.bottom, Constants.buttonBottomPadding)
        }
        .navigationBarBackButtonHidden(true)
        .background(.ypWhite)
    }
}

private extension PaymentSuccessView {
    enum Constants {
        static let title = "Успех! Оплата прошла,\nпоздравляем с покупкой!"
        static let buttonTitle = "Вернуться в корзину"

        static let imageSize: CGFloat = 278
        static let contentSpacing: CGFloat = 20
        static let horizontalPadding: CGFloat = 16

        static let buttonHeight: CGFloat = 60
        static let buttonCornerRadius: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 16
    }
}

#Preview {
    NavigationStack {
        PaymentSuccessView {
            // Preview action
        }
    }
}
