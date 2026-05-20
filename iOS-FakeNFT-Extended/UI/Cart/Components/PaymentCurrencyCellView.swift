import Kingfisher
import SwiftUI

struct PaymentCurrencyCellView: View {
    let currency: PaymentCurrency
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Constants.contentSpacing) {
                image

                VStack(alignment: .leading, spacing: Constants.nameSpacing) {
                    Text(currency.title)
                        .font(.regular13)
                        .foregroundStyle(.ypBlack)
                        .lineLimit(1)

                    Text(currency.name)
                        .font(.regular13)
                        .foregroundStyle(.ypGreenUniversal)
                        .lineLimit(1)
                }

                Spacer(minLength: .zero)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .frame(
                maxWidth: .infinity,
                minHeight: Constants.cellHeight,
                maxHeight: Constants.cellHeight,
                alignment: .leading
            )
            .background(.ypGrayLight)
            .overlay {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(
                        isSelected ? Color.ypBlack : Color.clear,
                        lineWidth: Constants.selectionLineWidth
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
            )
        }
        .buttonStyle(.plain)
    }

    private var image: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.imageBackgroundCornerRadius)
                .fill(.ypBlackUniversal)
                .frame(
                    width: Constants.imageBackgroundSize,
                    height: Constants.imageBackgroundSize
                )

            KFImage(currency.imageURL)
                .placeholder {
                    SkeletonView(cornerRadius: Constants.imageCornerRadius)
                        .frame(
                            width: Constants.imageSize,
                            height: Constants.imageSize
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: Constants.imageSize,
                    height: Constants.imageSize
                )
        }
        .frame(
            width: Constants.imageBackgroundSize,
            height: Constants.imageBackgroundSize
        )
    }
}

private extension PaymentCurrencyCellView {
    enum Constants {
        static let cellHeight: CGFloat = 46
        static let horizontalPadding: CGFloat = 12
        static let contentSpacing: CGFloat = 8
        static let nameSpacing: CGFloat = 0

        static let imageBackgroundSize: CGFloat = 36
        static let imageBackgroundCornerRadius: CGFloat = 6
        static let imageSize: CGFloat = 30
        static let imageCornerRadius: CGFloat = 6

        static let cornerRadius: CGFloat = 12
        static let selectionLineWidth: CGFloat = 1
    }
}
