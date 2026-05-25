import XCTest
@testable import iOS_FakeNFT_Extended

final class FavoritesServiceTests: XCTestCase {

    private var profileService: MockProfileService!
    private var service: FavoritesService!

    override func setUp() {
        super.setUp()
        profileService = MockProfileService()
        service = FavoritesService(profileService: profileService)
    }

    override func tearDown() {
        service = nil
        profileService = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeProfile(likes: [String], nfts: [String] = []) -> Profile {
        Profile(
            id: "test-id",
            name: "Test",
            description: nil,
            website: nil,
            avatar: nil,
            nfts: nfts,
            likes: likes
        )
    }

    // MARK: - loadFavorites

    func test_loadFavorites_extractsLikesFromProfile() async throws {
        profileService = MockProfileService(profile: makeProfile(likes: ["a", "b"]))
        service = FavoritesService(profileService: profileService)

        let favorites = try await service.loadFavorites()

        XCTAssertEqual(favorites, Set(["a", "b"]))
    }

    func test_loadFavorites_emptyLikes_returnsEmptySet() async throws {
        profileService = MockProfileService(profile: makeProfile(likes: []))
        service = FavoritesService(profileService: profileService)

        let favorites = try await service.loadFavorites()

        XCTAssertTrue(favorites.isEmpty)
    }

    // MARK: - setFavorites

    func test_setFavorites_writesLikesThroughProfileService() async throws {
        profileService = MockProfileService(profile: makeProfile(likes: ["a"], nfts: ["nft-1"]))
        service = FavoritesService(profileService: profileService)

        let result = try await service.setFavorites(Set(["a", "b", "c"]))

        XCTAssertEqual(result, Set(["a", "b", "c"]))
    }

    func test_setFavorites_preservesNfts() async throws {
        // Лайк не должен затирать купленные nfts профиля.
        profileService = MockProfileService(profile: makeProfile(likes: ["a"], nfts: ["nft-1", "nft-2"]))
        service = FavoritesService(profileService: profileService)

        _ = try await service.setFavorites(Set(["a", "b"]))

        let profile = try await profileService.loadProfile()
        XCTAssertEqual(Set(profile.nfts ?? []), Set(["nft-1", "nft-2"]),
                       "Updating likes must not wipe profile nfts")
    }

    func test_setFavorites_clearAll_returnsEmptySet() async throws {
        profileService = MockProfileService(profile: makeProfile(likes: ["a", "b"]))
        service = FavoritesService(profileService: profileService)

        let result = try await service.setFavorites([])

        XCTAssertTrue(result.isEmpty)
    }
}
