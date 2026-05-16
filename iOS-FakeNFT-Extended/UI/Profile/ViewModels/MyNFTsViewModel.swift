//
//  MyNFTsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 14.05.2026.
//

import Foundation
import Observation

enum MyNFTsSortOption {
    case price
    case rating
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

    var sortOption: MyNFTsSortOption = .price {
        didSet {
            applySort()
        }
    }

    private(set) var state: State = .idle

    // MARK: - Dependencies

    private let nftIds: [String]
    private let nftService: NftServiceProtocol

    // MARK: - Initializers

    init(nftIds: [String], nftService: NftServiceProtocol) {
        self.nftIds = nftIds
        self.nftService = nftService
    }

    // MARK: - Public Methods

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
        }
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
