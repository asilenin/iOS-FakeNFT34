//
//  MyNFTsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Kingfisher
import SwiftUI

struct MyNFTsView: View {

    // MARK: - State

    @State private var viewModel: MyNFTsViewModel
    @State private var isShowingSortDialog = false

    // MARK: - Initializers

    init(nftIds: [String], nftService: NftServiceProtocol) {
        _viewModel = State(
            initialValue: MyNFTsViewModel(
                nftIds: nftIds,
                nftService: nftService
            )
        )
    }

    // MARK: - Body

    var body: some View {
        content
            .navigationTitle(String(localized: "Profile.MyNFTs.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MenuButton {
                        isShowingSortDialog = true
                    }
                }
            }
            .confirmationDialog(
                String(localized: "Common.sort"),
                isPresented: $isShowingSortDialog,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Profile.MyNFTs.sort.price")) {
                    viewModel.sortOption = .price
                }

                Button(String(localized: "Profile.MyNFTs.sort.rating")) {
                    viewModel.sortOption = .rating
                }

                Button(String(localized: "Error.cancel"), role: .cancel) {}
            }
            .task {
                await viewModel.loadNFTs()
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingSpinner(size: .medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.ypWhite)
        case .loaded(let nfts):
            nftList(nfts)
        case .empty:
            emptyContent
        case .failed(let message):
            errorContent(message)
        }
    }

    private func nftList(_ nfts: [ProfileNft]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(nfts, id: \.profileListID) { nft in
                    MyNFTsRowView(nft: nft)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color.ypWhite)
    }

    private var emptyContent: some View {
        Text(String(localized: "Profile.MyNFTs.empty"))
            .font(.bold17)
            .foregroundStyle(Color.ypBlack)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.ypWhite)
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.bold17)
                .foregroundStyle(Color.ypBlack)
                .multilineTextAlignment(.center)

            Button(String(localized: "Profile.retry")) {
                Task {
                    await viewModel.loadNFTs()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ypWhite)
    }
}

// MARK: - MyNFTsRowView

private struct MyNFTsRowView: View {

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

            RatingStarsView(rating: nft.rating ?? 0)

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

        return String(format: "%.2f ETH", locale: Locale(identifier: "ru_RU"), price)
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
                NFTImagePlaceholder()
            }
        }
        .frame(width: 108, height: 108)
        .clipped()
    }
}

// MARK: - NFTImagePlaceholder

private struct NFTImagePlaceholder: View {

    // MARK: - Constants

    private enum Constants {
        static let cellSize: CGFloat = 27
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
        .frame(width: 108, height: 108)
    }
}

// MARK: - RatingStarsView

private struct RatingStarsView: View {

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

// MARK: - ProfileNft

private extension ProfileNft {
    var profileListID: String {
        id ?? "\(name ?? "")-\(author ?? "")-\(price ?? 0)"
    }
}

#Preview {
    NavigationStack {
        MyNFTsView(
            nftIds: [],
            nftService: NftService(networkClient: DefaultNetworkClient())
        )
    }
}
