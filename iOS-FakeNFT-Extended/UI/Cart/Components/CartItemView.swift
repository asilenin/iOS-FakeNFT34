//
//  CartItemView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Smirnov Michael on 11.05.2026.
//

import Kingfisher
import SwiftUI

struct CartItemView: View {
    let item: CartItem
    let onDeleteTap: () -> Void

    var body: some View {
        HStack(spacing: Constants.contentSpacing) {
            image

            VStack(alignment: .leading, spacing: Constants.textSpacing) {
                Text(item.title)
                    .font(.bold17)
                    .foregroundStyle(.ypBlack)
                    .lineLimit(2)

                ratingView

                Spacer()
                    .frame(height: Constants.priceTopSpacing)

                VStack(alignment: .leading, spacing: Constants.priceTextSpacing) {
                    Text("Цена")
                        .font(.regular13)
                        .foregroundStyle(.ypBlack)

                    Text(priceText)
                        .font(.bold17)
                        .foregroundStyle(.ypBlack)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDeleteTap) {
                Image(.cartDelete)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.ypBlack)
                    .frame(
                        width: Constants.deleteIconSize,
                        height: Constants.deleteIconSize
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Constants.verticalPadding)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.ypWhite)
    }

    private var image: some View {
        KFImage(item.imageURL)
            .placeholder {
                SkeletonView(cornerRadius: Constants.imageCornerRadius)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: Constants.imageSize, height: Constants.imageSize)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Constants.imageCornerRadius
                )
            )
    }

    private var ratingView: some View {
        HStack(spacing: Constants.starSpacing) {
            ForEach(1...Constants.maxRating, id: \.self) { index in
                Image(index <= item.rating ? "star-active" : "star-inactive")
                    .resizable()
                    .frame(
                        width: Constants.starSize,
                        height: Constants.starSize
                    )
            }
        }
    }

    private var priceText: String {
        String(format: "%.2f ETH", item.price)
            .replacingOccurrences(of: ".", with: ",")
    }
}

private extension CartItemView {
    enum Constants {
        static let contentSpacing: CGFloat = 12
        static let textSpacing: CGFloat = 4
        static let priceTopSpacing: CGFloat = 12
        static let priceTextSpacing: CGFloat = 2
        static let verticalPadding: CGFloat = 8
        static let imageSize: CGFloat = 108
        static let imageCornerRadius: CGFloat = 12
        static let deleteIconSize: CGFloat = 40
        static let starSize: CGFloat = 12
        static let starSpacing: CGFloat = 2
        static let maxRating = 5
    }
}
