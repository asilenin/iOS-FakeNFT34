import XCTest
@testable import iOS_FakeNFT_Extended

final class ProfileServiceCacheTests: XCTestCase {

    private var network: MockNetworkClient!
    private var service: ProfileService!

    override func setUp() {
        super.setUp()
        network = MockNetworkClient()
        service = ProfileService(networkClient: network)
    }

    override func tearDown() {
        service = nil
        network = nil
        super.tearDown()
    }

    private static let profileURL = "\(RequestConstants.baseURL)/api/v1/profile/1"

    private static func profileJSON(name: String = "Test", likes: [String] = []) -> Data {
        let likesArray = likes.map { "\"\($0)\"" }.joined(separator: ",")
        let json = """
        {
            "id": "test-id",
            "name": "\(name)",
            "likes": [\(likesArray)]
        }
        """
        return json.data(using: .utf8)!
    }

    // MARK: - loadProfile cache

    func test_loadProfile_secondCall_usesCache() async throws {
        await network.stub(url: Self.profileURL, data: Self.profileJSON())

        _ = try await service.loadProfile()
        _ = try await service.loadProfile()

        let count = await network.callCount(for: Self.profileURL)
        XCTAssertEqual(count, 1, "Second loadProfile must hit cache, not network")
    }

    func test_loadProfile_returnsSameData() async throws {
        await network.stub(url: Self.profileURL, data: Self.profileJSON(name: "Alice"))

        let first = try await service.loadProfile()
        let second = try await service.loadProfile()

        XCTAssertEqual(first.name, "Alice")
        XCTAssertEqual(second.name, "Alice")
    }

    // MARK: - invalidateCache

    func test_invalidateCache_forcesNextCallToNetwork() async throws {
        await network.stub(url: Self.profileURL, data: Self.profileJSON())

        _ = try await service.loadProfile()
        await service.invalidateCache()
        _ = try await service.loadProfile()

        let count = await network.callCount(for: Self.profileURL)
        XCTAssertEqual(count, 2, "After invalidate, loadProfile must hit network again")
    }

    // MARK: - updateProfile refreshes cache

    func test_updateProfile_cachesServerResponse() async throws {
        // updateProfile кладёт ответ сервера в кэш → следующий loadProfile без сети.
        await network.stub(url: Self.profileURL, data: Self.profileJSON(name: "Updated"))

        let updated = try await service.updateProfile(
            Profile(id: "test-id", name: "Updated", description: nil,
                    website: nil, avatar: nil, nfts: [], likes: [])
        )
        XCTAssertEqual(updated.name, "Updated")

        // loadProfile после updateProfile должен взять из кэша (без доп. сетевого вызова)
        let countAfterUpdate = await network.callCount(for: Self.profileURL)
        _ = try await service.loadProfile()
        let countAfterLoad = await network.callCount(for: Self.profileURL)

        XCTAssertEqual(countAfterLoad, countAfterUpdate,
                       "loadProfile after updateProfile must use cache, not network")
    }

    // MARK: - error propagation

    func test_loadProfile_propagatesError() async {
        await network.stub(url: Self.profileURL, error: NetworkClientError.httpStatusCode(500))

        do {
            _ = try await service.loadProfile()
            XCTFail("Expected error to propagate")
        } catch {
            // ok
        }
    }
}
