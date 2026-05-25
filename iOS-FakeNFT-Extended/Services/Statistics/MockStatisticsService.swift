//
//  MockStatisticsService.swift
//  iOS-FakeNFT-Extended
//
//  Created by МAK on 12.05.2026.
//

import Foundation

enum MockStatisticsServiceError: Error, LocalizedError {
    case simulatedFailure
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .simulatedFailure:
            return NSLocalizedString("Error.network", comment: "")
        case .userNotFound:
            return NSLocalizedString("Error.parsing", comment: "")
        }
    }
}

actor MockStatisticsService: StatisticsServiceProtocol {

    var shouldFailNextFetch = false
    var simulatedDelayNanoseconds: UInt64 = 350_000_000

    func fetchRankingUsers() async throws -> [StatisticsUser] {
        try await simulateNetwork()
        if shouldFailNextFetch {
            shouldFailNextFetch = false
            throw MockStatisticsServiceError.simulatedFailure
        }
        return Self.mockUsers
    }

    func fetchUserDetail(userId: String) async throws -> StatisticsUserDetail {
        try await simulateNetwork()
        guard let user = Self.mockUsers.first(where: { $0.id == userId }) else {
            throw MockStatisticsServiceError.userNotFound
        }
        return StatisticsUserDetail(
            summary: user,
            description: Self.mockDescriptions[userId] ?? "",
            websiteURL: Self.mockWebsiteURL
        )
    }

    func fetchUserNfts(userId: String) async throws -> [StatisticsNft] {
        try await simulateNetwork()
        guard let user = Self.mockUsers.first(where: { $0.id == userId }) else {
            throw MockStatisticsServiceError.userNotFound
        }
        return Self.nfts(for: user)
    }

    // MARK: - Private

    private func simulateNetwork() async throws {
        if simulatedDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
        }
    }
}

// MARK: - Mock data

private extension MockStatisticsService {

    static let mockWebsiteURL = URL(string: "https://practicum.yandex.ru")

    static let mockDescriptions: [String: String] = [
        "1": "Коллекционер digital-арта. Любит редкие NFT и делится находками в блоге.",
        "2": "Начинающий автор. Собирает коллекцию из плюшевых персонажей.",
        "3": "Топ автор платформы. Публикует крупные серии и участвует в рейтингах.",
        "4": "Минималист. Небольшая, но очень ценная подборка NFT.",
        "5": "Иллюстратор. Экспериментирует с цветом и формой в цифровых работах."
    ]

    static let mockAvatarURLs: [URL] = [
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!,
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png")!,
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/3.png")!,
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!,
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png")!
    ]

    static let mockUsers: [StatisticsUser] = [
        StatisticsUser(
            id: "1",
            name: "Alice",
            avatarURL: mockAvatarURLs[0],
            nftsCount: 42,
            rating: 98
        ),
        StatisticsUser(
            id: "2",
            name: "Bob",
            avatarURL: mockAvatarURLs[1],
            nftsCount: 17,
            rating: 72
        ),
        StatisticsUser(
            id: "3",
            name: "Clara",
            avatarURL: mockAvatarURLs[2],
            nftsCount: 105,
            rating: 100
        ),
        StatisticsUser(
            id: "4",
            name: "Dan",
            avatarURL: mockAvatarURLs[3],
            nftsCount: 3,
            rating: 40
        ),
        StatisticsUser(
            id: "5",
            name: "Eve",
            avatarURL: mockAvatarURLs[4],
            nftsCount: 64,
            rating: 88
        )
    ]

    struct NftTemplate {
        let baseName: String
        let imageURL: URL
        let rating: Int
        let price: Float
    }

    static let nftTemplates: [NftTemplate] = [
        NftTemplate(
            baseName: "Archie",
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!,
            rating: 2,
            price: 1.5
        ),
        NftTemplate(
            baseName: "Ruby",
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png")!,
            rating: 3,
            price: 2.0
        ),
        NftTemplate(
            baseName: "Nacho",
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/3.png")!,
            rating: 4,
            price: 1.8
        )
    ]

    static func nfts(for user: StatisticsUser) -> [StatisticsNft] {
        let count = min(max(user.nftsCount, 0), 10)
        guard count > 0 else { return [] }

        return (0..<count).map { index in
            let template = nftTemplates[index % nftTemplates.count]
            return StatisticsNft(
                id: "\(user.id)-nft-\(index)",
                name: "\(template.baseName) #\(index + 1)",
                imageURL: template.imageURL,
                rating: template.rating,
                price: template.price + Float(index) * 0.1
            )
        }
    }
}
