import Foundation

/// Мок-реализация `CollectionDetailServiceProtocol` для разработки UI без сети.
///
/// Возвращает захардкодированные NFT и автора с имитацией задержки сети.
/// Используется в P2 для разработки UI коллекции. В P3 заменяется
/// на реальный `CollectionDetailService`, работающий с API.
actor MockCollectionDetailService: CollectionDetailServiceProtocol {

    func loadNfts(byIds ids: [String]) async throws -> [Nft] {
        try await Task.sleep(for: .milliseconds(500))
        // В P2 моковые id NFT не совпадают с id из NftCollection.nfts (которые приходят
        // из MockCatalogService). Возвращаем столько NFT, сколько запрошено,
        // циклически проходя по моковому массиву.
        // В P3 этот мок будет заменён на реальный сервис с настоящими id.
        return ids.enumerated().map { index, id in
            let template = Self.mockNfts[index % Self.mockNfts.count]
            return Nft(
                id: id,
                createdAt: template.createdAt,
                name: template.name,
                images: template.images,
                rating: template.rating,
                description: template.description,
                price: template.price,
                author: template.author,
                website: template.website
            )
        }
    }

    func loadAuthor(by id: String) async throws -> Author {
        try await Task.sleep(for: .milliseconds(500))
        return Author(
            id: id,
            name: Self.mockAuthorName,
            website: Self.mockAuthorWebsite
        )
    }
}

// MARK: - Mock data

extension MockCollectionDetailService {

    private static let mockAuthorName = "John Doe"
    private static let mockAuthorWebsite = "https://practicum.yandex.ru"

    private static let mockImageURLs: [URL] = [
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!,
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png")!,
        URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/3.png")!
    ]

    static let mockNfts: [Nft] = [
        Nft(
            id: "archie_id",
            createdAt: "2024-01-15T10:30:00Z",
            name: "Archie",
            images: [mockImageURLs[0]],
            rating: 2,
            description: "A cute plush rabbit with blue eyes.",
            price: 1.5,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "ruby_id",
            createdAt: "2024-01-16T11:00:00Z",
            name: "Ruby",
            images: [mockImageURLs[1]],
            rating: 3,
            description: "A fluffy white cat with pink nose.",
            price: 2.0,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "nacho_id",
            createdAt: "2024-01-17T12:15:00Z",
            name: "Nacho",
            images: [mockImageURLs[2]],
            rating: 4,
            description: "A funny orange dog.",
            price: 1.8,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "biscuit_id",
            createdAt: "2024-01-18T13:45:00Z",
            name: "Biscuit",
            images: [mockImageURLs[0]],
            rating: 5,
            description: "A sweet little hamster.",
            price: 1.2,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "daisy_id",
            createdAt: "2024-01-19T14:20:00Z",
            name: "Daisy",
            images: [mockImageURLs[1]],
            rating: 3,
            description: "A beautiful butterfly.",
            price: 0.9,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "susan_id",
            createdAt: "2024-01-20T15:30:00Z",
            name: "Susan",
            images: [mockImageURLs[2]],
            rating: 2,
            description: "A sleepy owl.",
            price: 1.6,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "oreo_id",
            createdAt: "2024-01-21T16:00:00Z",
            name: "Oreo",
            images: [mockImageURLs[0]],
            rating: 4,
            description: "A black and white panda.",
            price: 2.2,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "pixi_id",
            createdAt: "2024-01-22T17:10:00Z",
            name: "Pixi",
            images: [mockImageURLs[1]],
            rating: 5,
            description: "A magical fairy.",
            price: 3.0,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "zoe_id",
            createdAt: "2024-01-23T18:25:00Z",
            name: "Zoe",
            images: [mockImageURLs[2]],
            rating: 3,
            description: "A playful lion cub.",
            price: 1.9,
            author: mockAuthorName,
            website: mockAuthorWebsite
        ),
        Nft(
            id: "tater_id",
            createdAt: "2024-01-24T19:40:00Z",
            name: "Tater",
            images: [mockImageURLs[0]],
            rating: 2,
            description: "A tiny potato with eyes.",
            price: 0.7,
            author: mockAuthorName,
            website: mockAuthorWebsite
        )
    ]
}
