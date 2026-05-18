import XCTest
@testable import iOS_FakeNFT_Extended

final class CatalogFavoritesServiceTests: XCTestCase {

    private var network: MockNetworkClient!
    private var service: CatalogFavoritesService!

    override func setUp() {
        super.setUp()
        network = MockNetworkClient()
        service = CatalogFavoritesService(networkClient: network)
    }

    override func tearDown() {
        service = nil
        network = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private static let profileURL = "\(RequestConstants.baseURL)/api/v1/profile/1"

    private static func profileJSON(likes: [String], id: String = "user-id") -> Data {
        let likesArray = likes.map { "\"\($0)\"" }.joined(separator: ",")
        let json = """
        {
            "id": "\(id)",
            "likes": [\(likesArray)]
        }
        """
        return json.data(using: .utf8)!
    }

    // MARK: - Tests

    func test_loadFavorites_returnsLikesFromServer() async throws {
        await network.stub(url: Self.profileURL, data: Self.profileJSON(likes: ["a", "b", "c"]))

        let favorites = try await service.loadFavorites()

        XCTAssertEqual(favorites, ["a", "b", "c"])
    }

    func test_loadFavorites_secondCallUsesCache() async throws {
        await network.stub(url: Self.profileURL, data: Self.profileJSON(likes: ["a"]))

        _ = try await service.loadFavorites()
        _ = try await service.loadFavorites()

        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 1, "Second loadFavorites must come from cache")
    }

    func test_setFavorites_returnsUpdatedSetFromServerResponse() async throws {
        // Server returns whatever we sent, in arbitrary order — set comparison is order-agnostic.
        await network.stub(url: Self.profileURL, data: Self.profileJSON(likes: ["x", "y"]))

        let updated = try await service.setFavorites(["x", "y"])

        XCTAssertEqual(updated, ["x", "y"])
    }

    func test_setFavorites_updatesCache() async throws {
        await network.stub(url: Self.profileURL, data: Self.profileJSON(likes: ["m"]))

        _ = try await service.setFavorites(["m"])
        // Subsequent load must NOT hit the network because cache is fresh.
        _ = try await service.loadFavorites()

        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 1, "loadFavorites after setFavorites must use the cache populated by setFavorites")
    }

    func test_setFavorites_propagatesNetworkError() async {
        await network.stub(url: Self.profileURL, error: NetworkClientError.httpStatusCode(500))

        do {
            _ = try await service.setFavorites(["x"])
            XCTFail("Expected error to propagate")
        } catch {
            // expected
        }
    }

    func test_invalidateCache_forcesNextLoadToHitNetwork() async throws {
        await network.stub(url: Self.profileURL, data: Self.profileJSON(likes: ["a"]))

        _ = try await service.loadFavorites()
        await service.invalidateCache()
        _ = try await service.loadFavorites()

        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 2)
    }

    func test_setFavorites_withEmptySet_stillCallsNetwork() async throws {
        // Even though the server will silently ignore empty likes,
        // the service still attempts the PUT — it doesn't filter empty sets.
        // The known limitation lives at the network-client layer.
        await network.stub(url: Self.profileURL, data: Self.profileJSON(likes: []))

        let updated = try await service.setFavorites([])

        XCTAssertEqual(updated, [])
        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 1)
    }
}
