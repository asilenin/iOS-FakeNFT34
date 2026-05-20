//
//  FavoriteNFTCell.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 19.05.2026.
//

import Kingfisher
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

            FavoriteRatingStarsView(rating: nft.rating ?? 0)
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

// MARK: - FavoriteNFTImageView

private struct FavoriteNFTImageView: View {

    // MARK: - State

    @State private var didFail = false

    // MARK: - Properties

    let url: URL?

    // MARK: - Body

    var body: some View {
        ZStack {
            if let url, !didFail {
                KFImage(url)
                    .placeholder {
                        ZStack {
                            Color.ypBackgroundUniversal

                            LoadingSpinner(size: .medium, tint: .ypWhiteUniversal)
                        }
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .fade(duration: 0.2)
                    .onFailure { _ in
                        didFail = true
                    }
                    .resizable()
                    .scaledToFill()
            } else {
                FavoriteNFTImagePlaceholder()
            }
        }
        .frame(width: 80, height: 80)
        .clipped()
    }
}

// MARK: - FavoriteNFTImagePlaceholder

private struct FavoriteNFTImagePlaceholder: View {

    // MARK: - Constants

    private enum Constants {
        static let cellSize: CGFloat = 20
        static let gridSize = 4
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<Constants.gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<Constants.gridSize, id: \.self) { column in
                        Rectangle()
                            .fill((row + column).isMultiple(of: 2) ? Color.ypWhite : Color.ypBlack)
                            .frame(width: Constants.cellSize, height: Constants.cellSize)
                    }
                }
            }
        }
        .frame(width: 80, height: 80)
    }
}

// MARK: - FavoriteRatingStarsView

private struct FavoriteRatingStarsView: View {

    // MARK: - Constants

    private enum Constants {
        static let maxRating = 5
        static let starSize: CGFloat = 12
        static let totalWidth: CGFloat = 60
    }

    // MARK: - Properties

    let rating: Int

    private var normalizedRating: Int {
        min(max(rating, 0), Constants.maxRating)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...Constants.maxRating, id: \.self) { index in
                Image(index <= normalizedRating ? .starActive : .starInactive)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.starSize, height: Constants.starSize)
            }
        }
        .frame(width: Constants.totalWidth, height: Constants.starSize, alignment: .leading)
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
