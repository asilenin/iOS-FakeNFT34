//
//  MyNFTsRowView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 18.05.2026.
//

import Kingfisher
import SwiftUI

struct MyNFTsRowView: View {

    // MARK: - State

    // TODO(profile epic S4): connect the like state to profile.likes.
    @State private var isLiked = true

    // MARK: - Properties

    let nft: ProfileNft

    // MARK: - Body

    var body: some View {
        HStack(spacing: 20) {
            nftImage

            nftInfo

            Spacer(minLength: 8)

            priceInfo
        }
        .frame(height: 108)
    }

    // MARK: - Content

    private var nftImage: some View {
        ZStack {
            NFTImageView(url: imageURL)

            likeButton
        }
        .frame(width: 108, height: 108)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var likeButton: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    isLiked.toggle()
                } label: {
                    Image(isLiked ? .favouritesActive : .favouritesInactive)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    private var nftInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nft.name ?? String(localized: "Profile.MyNFTs.unknownName"))
                .font(.bold17)
                .foregroundStyle(Color.ypBlack)
                .lineLimit(1)

            RatingStarsView(rating: nft.rating ?? 0, spacing: 0, totalWidth: 60)

            Text(nft.author ?? String(localized: "Profile.MyNFTs.unknownAuthor"))
                .font(.regular13)
                .foregroundStyle(Color.ypBlack)
                .lineLimit(1)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }

    private var priceInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(localized: "Profile.MyNFTs.price"))
                .font(.regular13)
                .foregroundStyle(Color.ypBlack)

            Text(priceText)
                .font(.bold17)
                .foregroundStyle(Color.ypBlack)
                .lineLimit(1)
        }
        .frame(maxHeight: .infinity, alignment: .center)
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

        return ETHPriceFormatter.eth(price)
    }
}

// MARK: - NFTImageView

private struct NFTImageView: View {

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
                        SkeletonView(cornerRadius: Constants.cornerRadius)
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .fade(duration: 0.2)
                    .onFailure { _ in
                        didFail = true
                    }
                    .resizable()
                    .scaledToFill()
            } else {
                SkeletonView(cornerRadius: Constants.cornerRadius)
            }
        }
        .frame(width: Constants.imageSize, height: Constants.imageSize)
        .clipped()
    }

    // MARK: - Constants

    private enum Constants {
        static let imageSize: CGFloat = 108
        static let cornerRadius: CGFloat = 8
    }
}

// MARK: - ProfileNft

extension ProfileNft {
    var profileListID: String {
        id ?? "\(name ?? "")-\(author ?? "")-\(price ?? 0)"
    }
}
