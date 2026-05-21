//
//  FavoriteNFTsView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 19.05.2026.
//

import SwiftUI

struct FavoriteNFTsView: View {

    // MARK: - State

    @State private var viewModel: FavoriteNFTsViewModel

    // MARK: - Properties

    private let onProfileUpdated: (Profile) -> Void

    // MARK: - Initializers

    init(
        favoriteIds: [String],
        nftService: NftServiceProtocol,
        updateFavoriteIds: @escaping ([String]) async throws -> Profile,
        onProfileUpdated: @escaping (Profile) -> Void
    ) {
        _viewModel = State(
            initialValue: FavoriteNFTsViewModel(
                favoriteIds: favoriteIds,
                nftService: nftService,
                updateFavoriteIds: updateFavoriteIds
            )
        )
        self.onProfileUpdated = onProfileUpdated
    }

    // MARK: - Body

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "Profile.FavoriteNFTs.title"))
                        .font(.bold17)
                        .foregroundStyle(Color.ypBlack)
                }
            }
            .alert(
                String(localized: "Error.title"),
                isPresented: removalErrorBinding
            ) {
                Button(String(localized: "Error.cancel"), role: .cancel) {
                    viewModel.dismissRemovalError()
                }

                Button(String(localized: "Error.retry")) {
                    Task {
                        await retryRemovingFavorite()
                    }
                }
            } message: {
                Text(viewModel.removalErrorMessage ?? "")
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
            favoritesGrid(nfts)
        case .empty:
            emptyContent
        case .failed(let message):
            errorContent(message)
        }
    }

    private func favoritesGrid(_ nfts: [ProfileNft]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 7),
                    GridItem(.flexible(), spacing: 0)
                ],
                spacing: 20
            ) {
                ForEach(nfts, id: \.profileListID) { nft in
                    FavoriteNFTCell(
                        nft: nft,
                        isRemoving: viewModel.pendingRemovalIds.contains(nft.id ?? "")
                    ) {
                        Task {
                            await removeFromFavorites(nft)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
        .background(Color.ypWhite)
    }

    private var emptyContent: some View {
        Text(String(localized: "Profile.FavoriteNFTs.empty"))
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

    // MARK: - Actions

    private func removeFromFavorites(_ nft: ProfileNft) async {
        guard let updatedProfile = await viewModel.removeFromFavorites(nft) else {
            return
        }

        onProfileUpdated(updatedProfile)
    }

    private func retryRemovingFavorite() async {
        guard let updatedProfile = await viewModel.retryFailedRemoval() else {
            return
        }

        onProfileUpdated(updatedProfile)
    }

    // MARK: - Bindings

    private var removalErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.removalErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissRemovalError()
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        FavoriteNFTsView(
            favoriteIds: ProfilePreviewData.profile.likes ?? [],
            nftService: MockNftService(),
            updateFavoriteIds: { favoriteIds in
                ProfilePreviewData.profile.updatingLikes(favoriteIds)
            },
            onProfileUpdated: { _ in }
        )
    }
}

private extension Profile {
    func updatingLikes(_ likes: [String]) -> Profile {
        Profile(
            id: id,
            name: name,
            description: description,
            website: website,
            avatar: avatar,
            nfts: nfts ?? [],
            likes: likes
        )
    }
}
