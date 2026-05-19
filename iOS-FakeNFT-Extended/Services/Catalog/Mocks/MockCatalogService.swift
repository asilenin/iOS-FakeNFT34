import Foundation

/// Мок `CatalogServiceProtocol` для Preview и тестов. Не кэширует.
actor MockCatalogService: CatalogServiceProtocol {

    private let collections: [NftCollection]

    init() {
        self.collections = MockCatalogService.mockCollections
    }

    func loadCollections(sortBy: CatalogSortOption?) async throws -> [NftCollection] {
        try await Task.sleep(for: .seconds(1))
        guard let sortBy else {
            return collections
        }
        return collections.sorted(by: sortBy.comparator)
    }

    func invalidateCache() {}
}

// MARK: - Mock data

extension MockCatalogService {

    static let mockCollections: [NftCollection] = [
        NftCollection(
            id: "1",
            name: "Peach",
            cover: coverURL(for: "Peach"),
            nfts: ["a01", "a02", "a03", "a04", "a05", "a06", "a07", "a08"],
            description: "Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.",
            author: "John Doe",
            website: mockAuthorWebsite,
            createdAt: "2024-04-20T02:22:27Z"
        ),
        NftCollection(
            id: "2",
            name: "Blue",
            cover: coverURL(for: "Blue"),
            nfts: ["b01", "b02", "b03", "b04", "b05", "b06"],
            description: "Голубой — как бескрайнее небо над горами после дождя. В этой коллекции собраны спокойные, но завораживающие персонажи со своей внутренней магией.",
            author: "John Doe",
            website: mockAuthorWebsite,
            createdAt: "2024-07-12T14:08:11Z"
        ),
        NftCollection(
            id: "3",
            name: "Brown",
            cover: coverURL(for: "Brown"),
            nfts: ["c01", "c02", "c03", "c04", "c05", "c06", "c07"],
            description: "Коричневый — как тёплое какао в осенний вечер. В этой коллекции уютные домашние существа, у каждого своя маленькая история.",
            author: "John Doe",
            website: mockAuthorWebsite,
            createdAt: "2024-10-03T09:45:00Z"
        ),
        NftCollection(
            id: "4",
            name: "Green",
            cover: coverURL(for: "Green"),
            nfts: ["d01", "d02", "d03", "d04", "d05", "d06", "d07", "d08", "d09"],
            description: "Зелёный — как лесная поляна, скрытая от посторонних глаз. В этой коллекции живут таинственные обитатели заповедных уголков.",
            author: "John Doe",
            website: mockAuthorWebsite,
            createdAt: "2025-01-15T18:30:42Z"
        ),
        NftCollection(
            id: "5",
            name: "Pink",
            cover: coverURL(for: "Pink"),
            nfts: ["e01", "e02", "e03", "e04", "e05"],
            description: "Розовый — как сахарная вата на летней ярмарке. В этой коллекции праздничные и беззаботные герои, наполненные весельем.",
            author: "John Doe",
            website: mockAuthorWebsite,
            createdAt: "2025-03-08T11:11:11Z"
        )
    ]

    private static let mockAuthorWebsite: URL = makeURL("https://practicum.yandex.ru")

    /// Path "Обложки_коллекций" is percent-encoded for compatibility with `URL(string:)`.
    private static func coverURL(for name: String) -> URL {
        let encodedFolder = "%D0%9E%D0%B1%D0%BB%D0%BE%D0%B6%D0%BA%D0%B8_%D0%BA%D0%BE%D0%BB%D0%BB%D0%B5%D0%BA%D1%86%D0%B8%D0%B9"
        return makeURL("https://code.s3.yandex.net/Mobile/iOS/NFT/\(encodedFolder)/\(name).png")
    }

    /// All URLs in mock data are constant string literals known at write time. A nil here would
    /// mean a typo in this very file, so we surface it as a programmer error rather than letting
    /// it silently degrade to a broken UI.
    private static func makeURL(_ raw: String) -> URL {
        guard let url = URL(string: raw) else {
            preconditionFailure("Invalid mock URL literal: \(raw)")
        }
        return url
    }
}
