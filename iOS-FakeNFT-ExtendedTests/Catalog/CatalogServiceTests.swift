import XCTest
@testable import iOS_FakeNFT_Extended

final class CatalogServiceTests: XCTestCase {

    private var network: MockNetworkClient!
    private var service: CatalogService!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        network = MockNetworkClient()
        service = CatalogService(networkClient: network)
    }

    override func tearDown() {
        service = nil
        network = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private static let baseURL = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/api/v1/collections"

    private static func sampleJSON() -> Data {
        let json = """
        [
            {
                "id": "id-1",
                "name": "Alpha",
                "cover": "https://example.com/cover1.png",
                "nfts": ["nft-1", "nft-2"],
                "description": "first",
                "author": "Alice",
                "website": "https://example.com/alice",
                "createdAt": "2024-01-01T00:00:00Z"
            },
            {
                "id": "id-2",
                "name": "Bravo",
                "cover": "https://example.com/cover2.png",
                "nfts": ["nft-3"],
                "description": "second",
                "author": "Bob",
                "website": "https://example.com/bob",
                "createdAt": "2024-01-02T00:00:00Z"
            }
        ]
        """
        return json.data(using: .utf8)!
    }

    // MARK: - Tests

    func test_loadCollections_noSortBy_decodesResponseAndCallsNetworkOnce() async throws {
        let url = "\(Self.baseURL)?size=1000"
        await network.stub(url: url, data: Self.sampleJSON())

        let collections = try await service.loadCollections(sortBy: nil)

        XCTAssertEqual(collections.count, 2)
        XCTAssertEqual(collections.map(\.id), ["id-1", "id-2"])
        let calls = await network.totalCalls
        XCTAssertEqual(calls, 1)
    }

    func test_loadCollections_sortByName_addsCorrectQueryParameter() async throws {
        let url = "\(Self.baseURL)?size=1000&sortBy=name"
        await network.stub(url: url, data: Self.sampleJSON())

        _ = try await service.loadCollections(sortBy: .name)

        let count = await network.callCount(for: url)
        XCTAssertEqual(count, 1, "Service must request the URL with sortBy=name")
    }

    func test_loadCollections_sortByNftCount_passesNftsQueryParameter() async throws {
        let url = "\(Self.baseURL)?size=1000&sortBy=nfts"
        await network.stub(url: url, data: Self.sampleJSON())

        _ = try await service.loadCollections(sortBy: .nftCount)

        let count = await network.callCount(for: url)
        XCTAssertEqual(count, 1, "Service must map .nftCount to sortBy=nfts")
    }

    func test_loadCollections_secondCallWithSameSort_usesCache() async throws {
        let url = "\(Self.baseURL)?size=1000&sortBy=name"
        await network.stub(url: url, data: Self.sampleJSON())

        _ = try await service.loadCollections(sortBy: .name)
        _ = try await service.loadCollections(sortBy: .name)

        let count = await network.callCount(for: url)
        XCTAssertEqual(count, 1, "Second call with the same sortBy must hit cache")
    }

    func test_loadCollections_differentSortKeys_makeSeparateNetworkCalls() async throws {
        let urlByName = "\(Self.baseURL)?size=1000&sortBy=name"
        let urlByCount = "\(Self.baseURL)?size=1000&sortBy=nfts"
        await network.stub(url: urlByName, data: Self.sampleJSON())
        await network.stub(url: urlByCount, data: Self.sampleJSON())

        _ = try await service.loadCollections(sortBy: .name)
        _ = try await service.loadCollections(sortBy: .nftCount)

        let total = await network.totalCalls
        XCTAssertEqual(total, 2)
    }

    func test_invalidateCache_forcesNextCallToGoToNetwork() async throws {
        let url = "\(Self.baseURL)?size=1000&sortBy=name"
        await network.stub(url: url, data: Self.sampleJSON())

        _ = try await service.loadCollections(sortBy: .name)
        await service.invalidateCache()
        _ = try await service.loadCollections(sortBy: .name)

        let count = await network.callCount(for: url)
        XCTAssertEqual(count, 2, "After invalidate, the next call must hit the network again")
    }

    func test_loadCollections_propagatesNetworkError() async {
        let url = "\(Self.baseURL)?size=1000"
        await network.stub(url: url, error: NetworkClientError.httpStatusCode(500))

        do {
            _ = try await service.loadCollections(sortBy: nil)
            XCTFail("Expected error to propagate")
        } catch let error as NetworkClientError {
            if case .httpStatusCode(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected httpStatusCode(500), got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkClientError, got \(error)")
        }
    }
}
