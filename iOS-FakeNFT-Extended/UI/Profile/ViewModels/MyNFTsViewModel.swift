//
//  MyNFTsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Foundation
import Observation

enum MyNFTsSortOption: String {
    case price
    case rating
    case name
}

@Observable
@MainActor
final class MyNFTsViewModel {

    // MARK: - State

    enum State {
        case idle
        case loading
        case loaded([ProfileNft])
        case empty
        case failed(String)
    }

    var sortOption: MyNFTsSortOption {
        didSet {
            userDefaults.set(sortOption.rawValue, forKey: Constants.sortOptionKey)
            applySort()
        }
    }

    private(set) var state: State = .idle
    private(set) var likedIds: Set<String>
    private(set) var pendingLikeIds: Set<String> = []

    // MARK: - Dependencies

    private let nftIds: [String]
    private let nftService: NftServiceProtocol
    private let updateFavoriteIds: ([String]) async throws -> Profile
    private let userDefaults: UserDefaults

    // MARK: - Initializers

    init(
        nftIds: [String],
        favoriteIds: [String],
        nftService: NftServiceProtocol,
        updateFavoriteIds: @escaping ([String]) async throws -> Profile,
        userDefaults: UserDefaults = .standard
    ) {
        self.nftIds = nftIds
        self.likedIds = Set(favoriteIds)
        self.nftService = nftService
        self.updateFavoriteIds = updateFavoriteIds
        self.userDefaults = userDefaults
        sortOption = MyNFTsSortOption(
            rawValue: userDefaults.string(forKey: Constants.sortOptionKey) ?? ""
        ) ?? .rating
    }

    // MARK: - Public Methods

    func isLiked(_ nft: ProfileNft) -> Bool {
        guard let id = nft.id else { return false }
        return likedIds.contains(id)
    }

    func toggleLike(_ nft: ProfileNft) async {
        guard let id = nft.id, !pendingLikeIds.contains(id) else { return }

        let previousLiked = likedIds
        var newLiked = likedIds
        if newLiked.contains(id) {
            newLiked.remove(id)
        } else {
            newLiked.insert(id)
        }

        pendingLikeIds.insert(id)
        likedIds = newLiked   // оптимистично

        do {
            let saved = try await updateFavoriteIds(Array(newLiked))
            likedIds = Set(saved.likes ?? [])
        } catch {
            likedIds = previousLiked   // откат
        }

        pendingLikeIds.remove(id)
    }

    func loadNFTs() async {
        guard !state.isLoading else { return }

        guard !nftIds.isEmpty else {
            state = .empty
            return
        }

        state = .loading

        do {
            let loadedNFTs = try await withThrowingTaskGroup(of: ProfileNft.self) { group in
                for nftId in nftIds {
                    group.addTask { [nftService] in
                        try await nftService.loadNft(id: nftId)
                    }
                }

                var nfts: [ProfileNft] = []
                for try await nft in group {
                    nfts.append(nft)
                }
                return nfts
            }

            state = loadedNFTs.isEmpty ? .empty : .loaded(sorted(loadedNFTs))
        } catch {
            let message = String(
                format: String(localized: "Profile.MyNFTs.error.load"),
                error.localizedDescription
            )
            state = .failed(message)
        }
    }

    // MARK: - Private Methods

    private func applySort() {
        guard case .loaded(let nfts) = state else { return }
        state = .loaded(sorted(nfts))
    }

    private func sorted(_ nfts: [ProfileNft]) -> [ProfileNft] {
        switch sortOption {
        case .price:
            nfts.sorted { ($0.price ?? 0) > ($1.price ?? 0) }
        case .rating:
            nfts.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .name:
            nfts.sorted {
                ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending
            }
        }
    }
}

// MARK: - Constants

private extension MyNFTsViewModel {
    enum Constants {
        static let sortOptionKey = "profile.myNfts.sortOption"
    }
}

// MARK: - MyNFTsViewModel.State

private extension MyNFTsViewModel.State {
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
