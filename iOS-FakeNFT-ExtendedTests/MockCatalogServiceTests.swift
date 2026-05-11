import XCTest
@testable import iOS_FakeNFT_Extended

final class MockCatalogServiceTests: XCTestCase {

    func test_loadCollections_returnsAtLeastFiveCollections() async throws {
        let service = MockCatalogService()

        let collections = try await service.loadCollections()

        XCTAssertGreaterThanOrEqual(collections.count, 5)
    }

    func test_loadCollections_containsAllExpectedNames() async throws {
        let service = MockCatalogService()

        let names = Set(try await service.loadCollections().map(\.name))

        XCTAssertTrue(names.isSuperset(of: ["Peach", "Blue", "Brown", "Green", "Pink"]))
    }

    func test_loadCollections_returnsUniqueIds() async throws {
        let service = MockCatalogService()

        let ids = try await service.loadCollections().map(\.id)

        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func test_loadCollections_everyCollectionHasNonEmptyMandatoryFields() async throws {
        let service = MockCatalogService()

        let collections = try await service.loadCollections()

        for collection in collections {
            XCTAssertFalse(collection.id.isEmpty, "id is empty for \(collection.name)")
            XCTAssertFalse(collection.name.isEmpty, "name is empty for \(collection.id)")
            XCTAssertFalse(collection.description.isEmpty, "description is empty for \(collection.name)")
            XCTAssertFalse(collection.author.isEmpty, "author is empty for \(collection.name)")
            XCTAssertFalse(collection.nfts.isEmpty, "nfts is empty for \(collection.name)")
        }
    }
}
