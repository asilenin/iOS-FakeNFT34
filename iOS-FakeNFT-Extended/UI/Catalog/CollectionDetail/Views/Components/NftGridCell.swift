import SwiftUI
import Kingfisher

/// Ячейка NFT в сетке коллекции.
///
/// Отображает изображение NFT, рейтинг, название, цену и кнопки избранного/корзины.
/// Размер: 108×172pt. Изображение: 108×108pt (corner radius 12pt).
/// Нижний блок содержит рейтинг, название с кнопкой корзины и цену.
/// Используется в `LazyVGrid` экрана коллекции (см. 2.8).
///
/// Принимает `NftGridCellConfiguration` (данные + UI-state) и
/// `NftGridCellActions` (действия пользователя). Такое разделение
/// упрощает Preview, тестирование и переиспользование ячейки
/// в других контекстах при расширении приложения.
struct NftGridCell: View {

    // MARK: - Input

    let configuration: NftGridCellConfiguration
    let actions: NftGridCellActions

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            imageWithFavoriteButton
            infoBlock
        }
        .frame(width: 108, height: 172)
        .contentShape(Rectangle())
        .onTapGesture(perform: actions.onCellTap)
    }

    // MARK: - Subviews

    private var imageWithFavoriteButton: some View {
        ZStack(alignment: .topTrailing) {
            KFImage(configuration.nft.images?.first)
                .resizable()
                .scaledToFill()
                .frame(width: 108, height: 108)
                .clipped()
                .cornerRadius(12)

            Button(action: actions.onFavoriteTap) {
                Image(systemName: configuration.isFavorite ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(configuration.isFavorite ? Color.red : Color.white)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
                    .opacity(configuration.isFavoriteDisabled ? 0.4 : 1.0)
            }
            .buttonStyle(.plain)
            .disabled(configuration.isFavoriteDisabled)
        }
        .frame(width: 108, height: 108)
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            RatingStarsView(rating: configuration.nft.rating ?? 0)
                .padding(.bottom, 5)

            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(configuration.nft.name ?? "—")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.ypBlack)
                        .lineLimit(1)

                    Text(priceString)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.ypBlack)
                }
                .frame(width: 68, alignment: .leading)

                Button(action: actions.onCartTap) {
                    Image(configuration.isInCart ? .cartDelete : .cartAdd)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.ypBlack)
                        .contentShape(Rectangle())
                        .opacity(configuration.isCartDisabled ? 0.4 : 1.0)
                }
                .buttonStyle(.plain)
                .disabled(configuration.isCartDisabled)
            }
        }
        .frame(width: 108, alignment: .topLeading)
    }

    // MARK: - Private

    private var priceString: String {
        guard let price = configuration.nft.price else { return "— ETH" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: price)) ?? "0"
        return "\(formatted) ETH"
    }
}

#Preview {
    HStack(spacing: 9) {
        NftGridCell(
            configuration: NftGridCellConfiguration(
                nft: MockCollectionDetailService.mockNfts[0],
                isFavorite: false,
                isInCart: false
            ),
            actions: .preview
        )

        NftGridCell(
            configuration: NftGridCellConfiguration(
                nft: MockCollectionDetailService.mockNfts[1],
                isFavorite: true,
                isInCart: true
            ),
            actions: .preview
        )
    }
    .padding()
    .background(Color.ypWhite)
}
