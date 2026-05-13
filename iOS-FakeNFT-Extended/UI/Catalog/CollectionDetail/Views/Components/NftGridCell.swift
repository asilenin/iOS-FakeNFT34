import SwiftUI
import Kingfisher

/// Ячейка NFT в сетке коллекции.
///
/// Отображает изображение NFT, рейтинг, название, цену и кнопки избранного/корзины.
/// Размер: 108×172pt. Изображение: 108×108pt (corner radius 12pt).
/// Нижний блок содержит рейтинг, название с кнопкой корзины и цену.
/// Используется в `LazyVGrid` экрана коллекции (см. 2.8).
struct NftGridCell: View {

    let nft: Nft
    let isFavorite: Bool
    let isInCart: Bool
    let onFavoriteTap: () -> Void
    let onCartTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            imageWithFavoriteButton
            infoBlock
        }
        .frame(width: 108, height: 172)
    }

    // MARK: - Subviews

    private var imageWithFavoriteButton: some View {
        ZStack(alignment: .topTrailing) {
            KFImage(nft.images.first)
                .resizable()
                .scaledToFill()
                .frame(width: 108, height: 108)
                .clipped()
                .cornerRadius(12)

            Button(action: onFavoriteTap) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isFavorite ? Color.red : Color.white)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 108, height: 108)
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            RatingStarsView(rating: nft.rating)
                .padding(.bottom, 5)

            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(nft.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.ypBlack)
                        .lineLimit(1)

                    Text(priceString)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.ypBlack)
                }
                .frame(width: 68, alignment: .leading)

                Button(action: onCartTap) {
                    Image(isInCart ? .cartDelete : .cartAdd)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.ypBlack)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 108, alignment: .topLeading)
    }

    // MARK: - Private

    private var priceString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        let price = formatter.string(from: NSNumber(value: nft.price)) ?? "0"
        return "\(price) ETH"
    }
}

#Preview {
    HStack(spacing: 9) {
        NftGridCell(
            nft: MockCollectionDetailService.mockNfts[0],
            isFavorite: false,
            isInCart: false,
            onFavoriteTap: {},
            onCartTap: {}
        )

        NftGridCell(
            nft: MockCollectionDetailService.mockNfts[1],
            isFavorite: true,
            isInCart: true,
            onFavoriteTap: {},
            onCartTap: {}
        )
    }
    .padding()
    .background(Color.ypWhite)
}
