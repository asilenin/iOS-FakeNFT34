import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class MyNFTsViewModelTests: XCTestCase {

    private func makeProfile(likes: [String]) -> Profile {
        Profile(
            id: "test-id",
            name: "Test",
            description: nil,
            website: nil,
            avatar: nil,
            nfts: [],
            likes: likes
        )
    }

    private func makeNft(id: String) -> ProfileNft {
        ProfileNft(
            id: id,
            name: "NFT \(id)",
            images: ["https://example.com/\(id).png"],
            rating: 3,
            author: "Author",
            price: 1.0
        )
    }

    private enum TestError: Error { case failed }

    // MARK: - isLiked

    func test_isLiked_reflectsInitialFavorites() {
        let viewModel = MyNFTsViewModel(
            nftIds: ["a", "b"],
            favoriteIds: ["a"],
            nftService: MockNftService(),
            updateFavoriteIds: { _ in self.makeProfile(likes: ["a"]) }
        )

        XCTAssertTrue(viewModel.isLiked(makeNft(id: "a")))
        XCTAssertFalse(viewModel.isLiked(makeNft(id: "b")))
    }

    // MARK: - toggleLike success

    func test_toggleLike_addsLike_optimisticallyAndConfirms() async {
        let viewModel = MyNFTsViewModel(
            nftIds: ["a", "b"],
            favoriteIds: [],
            nftService: MockNftService(),
            updateFavoriteIds: { ids in self.makeProfile(likes: ids) }
        )

        await viewModel.toggleLike(makeNft(id: "a"))

        XCTAssertTrue(viewModel.isLiked(makeNft(id: "a")),
                      "Liking must add id to likedIds")
        XCTAssertFalse(viewModel.pendingLikeIds.contains("a"),
                       "Pending must be cleared after completion")
    }

    func test_toggleLike_removesExistingLike() async {
        let viewModel = MyNFTsViewModel(
            nftIds: ["a"],
            favoriteIds: ["a"],
            nftService: MockNftService(),
            updateFavoriteIds: { ids in self.makeProfile(likes: ids) }
        )

        await viewModel.toggleLike(makeNft(id: "a"))

        XCTAssertFalse(viewModel.isLiked(makeNft(id: "a")),
                       "Toggling an existing like must remove it")
    }

    func test_toggleLike_usesServerResponseAsTruth() async {
        // Сервер возвращает свои likes — VM должен взять именно их.
        let viewModel = MyNFTsViewModel(
            nftIds: ["a", "b"],
            favoriteIds: [],
            nftService: MockNftService(),
            updateFavoriteIds: { _ in self.makeProfile(likes: ["a", "server-extra"]) }
        )

        await viewModel.toggleLike(makeNft(id: "a"))

        XCTAssertTrue(viewModel.isLiked(makeNft(id: "a")))
        XCTAssertTrue(viewModel.isLiked(makeNft(id: "server-extra")),
                      "VM must adopt server likes as source of truth")
    }

    // MARK: - toggleLike rollback

    func test_toggleLike_onError_rollsBack() async {
        let viewModel = MyNFTsViewModel(
            nftIds: ["a"],
            favoriteIds: [],
            nftService: MockNftService(),
            updateFavoriteIds: { _ in throw TestError.failed }
        )

        await viewModel.toggleLike(makeNft(id: "a"))

        XCTAssertFalse(viewModel.isLiked(makeNft(id: "a")),
                       "On error likedIds must roll back to previous state")
        XCTAssertFalse(viewModel.pendingLikeIds.contains("a"),
                       "Pending must be cleared even on error")
    }

    func test_toggleLike_onError_preservesOtherLikes() async {
        let viewModel = MyNFTsViewModel(
            nftIds: ["a", "b"],
            favoriteIds: ["b"],
            nftService: MockNftService(),
            updateFavoriteIds: { _ in throw TestError.failed }
        )

        await viewModel.toggleLike(makeNft(id: "a"))

        XCTAssertTrue(viewModel.isLiked(makeNft(id: "b")),
                      "Existing likes must survive a failed toggle of another id")
        XCTAssertFalse(viewModel.isLiked(makeNft(id: "a")))
    }
}
