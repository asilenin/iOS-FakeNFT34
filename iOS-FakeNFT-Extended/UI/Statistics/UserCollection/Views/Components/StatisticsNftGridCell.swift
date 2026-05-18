//
//  StatisticsNftGridCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 17.05.2026.
//

import SwiftUI
import Kingfisher

struct StatisticsNftGridCell: View {

    let configuration: StatisticsNftGridCellConfiguration
    let actions: StatisticsNftGridCellActions

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
            KFImage(configuration.nft.imageURL)
                .placeholder { LoadingSpinner(size: .small) }
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
            }
            .buttonStyle(.plain)
        }
        .frame(width: 108, height: 108)
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            RatingStarsView(rating: configuration.nft.rating)
                .padding(.bottom, 5)

            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    nameLabel
                    priceLabel
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
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 108, alignment: .topLeading)
    }

    private var nameLabel: some View {
        Text(configuration.nft.name)
            .font(.bold17)
            .foregroundStyle(Color.ypBlack)
            .lineLimit(1)
    }

    private var priceLabel: some View {
        Text(priceString)
            .font(.medium10)
            .foregroundStyle(Color.ypBlack)
    }
    
    private var priceBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Statistics.nft.priceLabel")
                .font(.medium10)
                .foregroundStyle(Color.ypGrayUniversal)
            Text(priceString)
                .font(.medium10)
                .foregroundStyle(Color.ypBlack)
        }
    }

    private var priceString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: configuration.nft.price)) ?? "0"
        return "\(formatted) ETH"
    }
}
