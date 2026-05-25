import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class RouterTests: XCTestCase {

    private let mockCollection = MockCatalogService.mockCollections[0]

    func test_initialState_defaultsToCatalogTab_withEmptyPaths() {
        let router = Router()

        XCTAssertEqual(router.selectedTab, .catalog)
        XCTAssertTrue(router.catalogPath.isEmpty)
        XCTAssertTrue(router.cartPath.isEmpty)
        XCTAssertTrue(router.profilePath.isEmpty)
        XCTAssertTrue(router.statisticsPath.isEmpty)
    }

    func test_switchTo_changesSelectedTab() {
        let router = Router()

        router.switchTo(.cart)

        XCTAssertEqual(router.selectedTab, .cart)
    }

    func test_push_appendsToTheTargetTabPath_only() {
        let router = Router()

        router.push(CatalogRoute.collection(mockCollection), in: .catalog)

        XCTAssertEqual(router.catalogPath.count, 1)
        XCTAssertTrue(router.cartPath.isEmpty)
        XCTAssertTrue(router.profilePath.isEmpty)
        XCTAssertTrue(router.statisticsPath.isEmpty)
    }

    func test_pop_removesLastFromTargetTabPath() {
        let router = Router()
        router.push(CatalogRoute.collection(mockCollection), in: .catalog)
        router.push(CatalogRoute.collection(mockCollection), in: .catalog)
        XCTAssertEqual(router.catalogPath.count, 2)

        router.pop(in: .catalog)

        XCTAssertEqual(router.catalogPath.count, 1)
    }

    func test_pop_onEmptyPath_doesNothing() {
        let router = Router()

        router.pop(in: .profile)

        XCTAssertTrue(router.profilePath.isEmpty)
    }

    func test_popToRoot_resetsTargetTabPath_only() {
        let router = Router()
        router.push(CatalogRoute.collection(mockCollection), in: .catalog)
        router.push(CartRoute.payment, in: .cart)

        router.popToRoot(in: .catalog)

        XCTAssertTrue(router.catalogPath.isEmpty)
        XCTAssertEqual(router.cartPath.count, 1, "Other tabs must stay untouched")
    }
}
