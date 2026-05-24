//
//  MyNFTsRowView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 18.05.2026.
//

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
            ProfileNFTImageView(
                url: imageURL,
                size: Constants.imageSize,
                cornerRadius: Constants.imageCornerRadius
            )

            likeButton
        }
        .frame(width: Constants.imageSize, height: Constants.imageSize)
        .clipShape(RoundedRectangle(cornerRadius: Constants.imageCornerRadius))
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

private extension MyNFTsRowView {
    enum Constants {
        static let imageSize: CGFloat = 108
        static let imageCornerRadius: CGFloat = 8
    }
}

// MARK: - ProfileNft

extension ProfileNft {
    var profileListID: String {
        id ?? "\(name ?? "")-\(author ?? "")-\(price ?? 0)"
    }
}
