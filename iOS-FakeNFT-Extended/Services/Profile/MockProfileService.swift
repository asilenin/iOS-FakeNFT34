//
//  MockProfileService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Анастасия Федотова on 18.05.2026.
//

import Foundation

actor MockProfileService: ProfileServiceProtocol, NftServiceProtocol {

    // MARK: - Test Data

    static let nfts = [
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

    static let profile = Profile(
        id: "mock-profile",
        name: "Joaquin Phoenix",
        description: "Дизайнер из Казани",
        website: "https://example.com",
        avatar: nil,
        nfts: nfts.compactMap(\.id),
        likes: Array(nfts.compactMap(\.id).suffix(2))
    )

    // MARK: - State

    private var currentProfile: Profile

    // MARK: - Initializers

    init(profile: Profile = MockProfileService.profile) {
        currentProfile = profile
    }

    // MARK: - ProfileServiceProtocol

    func loadProfile() async throws -> Profile {
        currentProfile
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        currentProfile = profile
        return profile
    }

    // MARK: - NftServiceProtocol

    func loadNft(id: String) async throws -> ProfileNft {
        guard let nft = Self.nfts.first(where: { $0.id == id }) else {
            throw URLError(.fileDoesNotExist)
        }

        return nft
    }
}
