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
            #if DEBUG
            state = .loaded(sorted(Self.mockNFTs))
            #else
            state = .empty
            #endif
            return
        }

        state = .loading

        do {
            var loadedNFTs: [ProfileNft] = []

            for nftId in nftIds {
                loadedNFTs.append(try await nftService.loadNft(id: nftId))
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

    #if DEBUG
    private static let mockNFTs = [
        ProfileNft(
            id: "mock-1",
            name: "April-1",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"],
            rating: 3,
            author: "Joaquin Phoenix",
            price: 1.81
        ),
        ProfileNft(
            id: "mock-2",
            name: "April-2",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png"],
            rating: 4,
            author: "Anastasia",
            price: 3.42
        ),
        ProfileNft(
            id: "mock-3",
            name: "April-3",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/3.png"],
            rating: 5,
            author: "Practicum",
            price: 1.17
        )
    ]
    #endif
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
