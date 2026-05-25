//
//  MyNFTsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import SwiftUI

struct MyNFTsView: View {

    // MARK: - State

    @State private var viewModel: MyNFTsViewModel
    @State private var isShowingSortDialog = false

    // MARK: - Initializers

    init(
        nftIds: [String],
        favoriteIds: [String],
        nftService: NftServiceProtocol,
        updateFavoriteIds: @escaping ([String]) async throws -> Profile
    ) {
        _viewModel = State(
            initialValue: MyNFTsViewModel(
                nftIds: nftIds,
                favoriteIds: favoriteIds,
                nftService: nftService,
                updateFavoriteIds: updateFavoriteIds
            )
        )
    }

    // MARK: - Body

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "Profile.MyNFTs.title"))
                        .font(.bold17)
                        .foregroundStyle(Color.ypBlack)
                }

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
                Button(String(localized: "Profile.MyNFTs.sort.name")) {
                    viewModel.sortOption = .name
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
                    MyNFTsRowView(
                        nft: nft,
                        isLiked: viewModel.isLiked(nft),
                        isLikePending: viewModel.pendingLikeIds.contains(nft.id ?? ""),
                        onLikeToggle: {
                            Task { await viewModel.toggleLike(nft) }
                        }
                    )
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

#Preview {
    NavigationStack {
        MyNFTsView(
            nftIds: ProfilePreviewData.nfts.compactMap(\.id),
            favoriteIds: Array(ProfilePreviewData.nfts.compactMap(\.id).suffix(2)),
            nftService: MockNftService(),
            updateFavoriteIds: { _ in ProfilePreviewData.profile }
        )
    }
}
