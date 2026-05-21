//
//  FavoriteNFTCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 19.05.2026.
//

import SwiftUI

struct FavoriteNFTCell: View {

    // MARK: - Properties

    let nft: ProfileNft
    let isRemoving: Bool
    let onRemove: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            imageWithRemoveButton
            infoBlock
        }
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80, alignment: .leading)
    }

    // MARK: - Content

    private var imageWithRemoveButton: some View {
        ZStack(alignment: .topTrailing) {
            FavoriteNFTImageView(url: imageURL)

            Button(action: onRemove) {
                Image(.favouritesActive)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
                    .opacity(isRemoving ? 0.4 : 1)
            }
            .buttonStyle(.plain)
            .disabled(isRemoving)
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(nft.name ?? String(localized: "Profile.MyNFTs.unknownName"))
                .font(.bold17)
                .foregroundStyle(Color.ypBlack)
                .lineLimit(1)

            RatingStarsView(rating: nft.rating ?? 0, spacing: 0, totalWidth: 60)
                .padding(.top, 4)

            Text(priceText)
                .font(.regular15)
                .foregroundStyle(Color.ypBlack)
                .lineLimit(1)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80, alignment: .topLeading)
    }

    // MARK: - Helpers

    private var imageURL: URL? {
        guard let image = nft.images?.first else {
            return nil
        }

        return URL(string: image)
    }

    private var priceText: String {
        guard let price = nft.price else {
            return String(localized: "Profile.MyNFTs.noPrice")
        }

        return String(format: "%.2f ETH", locale: Locale(identifier: "ru_RU"), price)
    }
}

#Preview {
    FavoriteNFTCell(
        nft: ProfilePreviewData.nfts[0],
        isRemoving: false,
        onRemove: {}
    )
    .padding()
}
