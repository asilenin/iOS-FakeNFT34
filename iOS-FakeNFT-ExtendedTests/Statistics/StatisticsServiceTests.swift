import XCTest
@testable import iOS_FakeNFT_Extended

final class StatisticsServiceTests: XCTestCase {

    private var network: MockNetworkClient!
    private var service: StatisticsService!

    // pageSize маленький, чтобы тестировать пагинацию малым числом записей
    private let pageSize = 2

    override func setUp() {
        super.setUp()
        network = MockNetworkClient()
        service = StatisticsService(networkClient: network, pageSize: pageSize)
    }

    override func tearDown() {
        service = nil
        network = nil
        super.tearDown()
    }

    private struct UserFixture {
        let id: String
        let name: String
        let rating: String
        let nfts: [String]
    }

    private static let baseUsers = "\(RequestConstants.baseURL)/api/v1/users"

    private func usersURL(page: Int) -> String {
        "\(Self.baseUsers)?page=\(page)&size=\(pageSize)"
    }

    private func usersJSON(_ entries: [UserFixture]) -> Data {
        let items = entries.map { entry in
            let nftsArray = entry.nfts.map { "\"\($0)\"" }.joined(separator: ",")
            return """
            {
                "id": "\(entry.id)",
                "name": "\(entry.name)",
                "avatar": null,
                "description": null,
                "website": null,
                "nfts": [\(nftsArray)],
                "rating": "\(entry.rating)"
            }
            """
        }.joined(separator: ",")
        return Data("[\(items)]".utf8)
    }

    // MARK: - fetchRankingUsers

    func test_fetchRankingUsers_singlePage_stopsWhenPageNotFull() async throws {
        // 1 запись при pageSize 2 → неполная страница → один запрос, стоп.
        await network.stub(url: usersURL(page: 0),
                           data: usersJSON([UserFixture(id: "a", name: "Alice", rating: "5", nfts: [])]))

        let users = try await service.fetchRankingUsers()

        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.name, "Alice")
        let page0 = await network.callCount(for: usersURL(page: 0))
        XCTAssertEqual(page0, 1)
    }

    func test_fetchRankingUsers_paginatesUntilPartialPage() async throws {
        // page 0: полная (2 записи) → запросить page 1.
        // page 1: неполная (1 запись) → стоп.
        await network.stub(url: usersURL(page: 0),
                           data: usersJSON([
                            UserFixture(id: "a", name: "A", rating: "1", nfts: []),
                            UserFixture(id: "b", name: "B", rating: "2", nfts: [])
                           ]))
        await network.stub(url: usersURL(page: 1),
                           data: usersJSON([UserFixture(id: "c", name: "C", rating: "3", nfts: [])]))

        let users = try await service.fetchRankingUsers()

        XCTAssertEqual(users.count, 3)
        XCTAssertEqual(Set(users.map(\.id)), Set(["a", "b", "c"]))
        let page1 = await network.callCount(for: usersURL(page: 1))
        XCTAssertEqual(page1, 1, "Must request page 1 after a full page 0")
    }

    func test_fetchRankingUsers_mapsRatingAndNftCount() async throws {
        await network.stub(url: usersURL(page: 0),
                           data: usersJSON([UserFixture(id: "a", name: "Alice", rating: "42", nfts: ["n1", "n2", "n3"])]))

        let users = try await service.fetchRankingUsers()

        XCTAssertEqual(users.first?.rating, 42, "String rating must parse via FlexibleInt")
        XCTAssertEqual(users.first?.nftsCount, 3, "nftsCount must equal number of nft ids")
    }

    func test_fetchRankingUsers_propagatesError() async {
        await network.stub(url: usersURL(page: 0),
                           error: NetworkClientError.httpStatusCode(500))

        do {
            _ = try await service.fetchRankingUsers()
            XCTFail("Expected error to propagate")
        } catch {
            // ok
        }
    }
}
