import XCTest
@testable import iOS_FakeNFT_Extended

final class CartServiceCacheTests: XCTestCase {

    private var network: MockNetworkClient!
    private var service: CartService!

    override func setUp() {
        super.setUp()
        network = MockNetworkClient()
        service = CartService(networkClient: network, catalogNetworkClient: network)
    }

    override func tearDown() {
        service = nil
        network = nil
        super.tearDown()
    }

    private static let orderURL = "\(RequestConstants.baseURL)/api/v1/orders/1"

    private static func orderJSON(nfts: [String], id: String = "order-id") -> Data {
        let nftsArray = nfts.map { "\"\($0)\"" }.joined(separator: ",")
        let json = """
        {
            "id": "\(id)",
            "nfts": [\(nftsArray)]
        }
        """
        return json.data(using: .utf8)!
    }

    func test_loadCart_returnsNftIdsFromServer() async throws {
        await network.stub(url: Self.orderURL, data: Self.orderJSON(nfts: ["a", "b", "c"]))

        let cart = try await service.loadCart()

        XCTAssertEqual(cart, ["a", "b", "c"])
    }

    func test_loadCart_secondCallUsesCache() async throws {
        await network.stub(url: Self.orderURL, data: Self.orderJSON(nfts: ["a"]))

        _ = try await service.loadCart()
        _ = try await service.loadCart()

        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 1)
    }

    func test_setCart_returnsUpdatedSetFromServerResponse() async throws {
        await network.stub(url: Self.orderURL, data: Self.orderJSON(nfts: ["x", "y"]))

        let updated = try await service.setCart(["x", "y"])

        XCTAssertEqual(updated, ["x", "y"])
    }

    func test_setCart_updatesCache() async throws {
        await network.stub(url: Self.orderURL, data: Self.orderJSON(nfts: ["m"]))

        _ = try await service.setCart(["m"])
        _ = try await service.loadCart()

        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 1)
    }

    func test_setCart_propagatesNetworkError() async {
        await network.stub(url: Self.orderURL, error: NetworkClientError.httpStatusCode(500))

        do {
            _ = try await service.setCart(["x"])
            XCTFail("Expected error to propagate")
        } catch {
            // expected
        }
    }

    func test_invalidateCache_forcesNextLoadToHitNetwork() async throws {
        await network.stub(url: Self.orderURL, data: Self.orderJSON(nfts: ["a"]))

        _ = try await service.loadCart()
        await service.invalidateCache()
        _ = try await service.loadCart()

        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 2)
    }

    func test_setCart_withEmptySet_stillCallsNetwork() async throws {
        await network.stub(url: Self.orderURL, data: Self.orderJSON(nfts: []))

        let updated = try await service.setCart([])

        XCTAssertEqual(updated, [])
        let totalCalls = await network.totalCalls
        XCTAssertEqual(totalCalls, 1)
    }
}
