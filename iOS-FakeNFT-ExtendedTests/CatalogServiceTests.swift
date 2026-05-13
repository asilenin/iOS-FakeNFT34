import XCTest
@testable import iOS_FakeNFT_Extended

// MARK: - CatalogServiceTests

final class CatalogServiceTests: XCTestCase {

    // MARK: - Properties

    private var service: MockCatalogService!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        service = MockCatalogService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_loadCollections_returnsAtLeastFiveCollections() async throws {
        // When
        let collections = try await service.loadCollections()

        // Then
        XCTAssertGreaterThanOrEqual(collections.count, 5)
    }

    func test_loadCollections_containsAllExpectedNames() async throws {
        // Given
        let expectedNames = ["Peach", "Blue", "Brown", "Green", "Pink"]

        // When
        let names = Set(try await service.loadCollections().map(\.name))

        // Then
        XCTAssertTrue(names.isSuperset(of: expectedNames))
    }

    func test_loadCollections_returnsUniqueIds() async throws {
        // When
        let ids = try await service.loadCollections().map(\.id)

        // Then
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func test_loadCollections_everyCollectionHasNonEmptyMandatoryFields() async throws {
        // When
        let collections = try await service.loadCollections()

        // Then
        for collection in collections {
            XCTAssertFalse(collection.id.isEmpty, "id is empty for \(collection.name)")
            XCTAssertFalse(collection.name.isEmpty, "name is empty for \(collection.id)")
            XCTAssertFalse(collection.description.isEmpty, "description is empty for \(collection.name)")
            XCTAssertFalse(collection.author.isEmpty, "author is empty for \(collection.name)")
            XCTAssertFalse(collection.nfts.isEmpty, "nfts is empty for \(collection.name)")
        }
    }
}
