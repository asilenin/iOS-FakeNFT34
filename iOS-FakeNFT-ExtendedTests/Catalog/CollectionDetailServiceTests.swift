import XCTest
@testable import iOS_FakeNFT_Extended

final class CollectionDetailServiceTests: XCTestCase {

    private var network: MockNetworkClient!
    private var service: CollectionDetailService!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        network = MockNetworkClient()
        service = CollectionDetailService(networkClient: network)
    }

    override func tearDown() {
        service = nil
        network = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private static let baseURL = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/api/v1/nft"

    private static func nftURL(id: String) -> String {
        "\(baseURL)/\(id)"
    }

    private static func nftJSON(id: String) -> Data {
        let json = """
        {
            "id": "\(id)",
            "name": "NFT \(id)",
            "images": ["https://example.com/\(id).png"],
            "rating": 3,
            "description": "description for \(id)",
            "price": 1.5,
            "author": "Alice",
            "website": "https://example.com",
            "createdAt": "2024-01-01T00:00:00Z"
        }
        """
        return json.data(using: .utf8)!
    }

    // MARK: - Tests

    func test_loadNfts_emptyIds_returnsEmptyArrayWithoutNetworkCalls() async throws {
        let result = try await service.loadNfts(byIds: [])

        XCTAssertEqual(result, [])
        let total = await network.totalCalls
        XCTAssertEqual(total, 0, "Empty ids must short-circuit before any network call")
    }

    func test_loadNfts_duplicateIds_dedupesToSingleRequest() async throws {
        let url = Self.nftURL(id: "a")
        await network.stub(url: url, data: Self.nftJSON(id: "a"))

        let result = try await service.loadNfts(byIds: ["a", "a", "a"])

        XCTAssertEqual(result.count, 1)
        let count = await network.callCount(for: url)
        XCTAssertEqual(count, 1, "Three same ids must produce a single network call")
    }

    func test_loadNfts_partialFailure_returnsSuccessfulNftsOnly() async throws {
        await network.stub(url: Self.nftURL(id: "a"), data: Self.nftJSON(id: "a"))
        await network.stub(url: Self.nftURL(id: "b"), error: NetworkClientError.httpStatusCode(404))
        await network.stub(url: Self.nftURL(id: "c"), data: Self.nftJSON(id: "c"))

        let result = try await service.loadNfts(byIds: ["a", "b", "c"])

        let returnedIds = Set(result.map(\.id))
        XCTAssertEqual(returnedIds, ["a", "c"], "Failed NFTs must be silently skipped")
    }

    func test_loadNfts_allRequestsFail_throwsError() async {
        await network.stub(url: Self.nftURL(id: "a"), error: NetworkClientError.httpStatusCode(500))

        do {
            _ = try await service.loadNfts(byIds: ["a"])
            XCTFail("Expected error when all requests fail")
        } catch {
            // Expected
        }
    }

    func test_loadNfts_secondCallWithSameId_usesCache() async throws {
        let url = Self.nftURL(id: "a")
        await network.stub(url: url, data: Self.nftJSON(id: "a"))

        _ = try await service.loadNfts(byIds: ["a"])
        _ = try await service.loadNfts(byIds: ["a"])

        let count = await network.callCount(for: url)
        XCTAssertEqual(count, 1, "Second call must serve the cached NFT")
    }

    func test_invalidateCache_forcesNextCallToGoToNetwork() async throws {
        let url = Self.nftURL(id: "a")
        await network.stub(url: url, data: Self.nftJSON(id: "a"))

        _ = try await service.loadNfts(byIds: ["a"])
        await service.invalidateCache()
        _ = try await service.loadNfts(byIds: ["a"])

        let count = await network.callCount(for: url)
        XCTAssertEqual(count, 2)
    }
}
