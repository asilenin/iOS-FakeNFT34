import Foundation

protocol FavoritesServiceProtocol: Sendable {

    /// Fetches the current set of liked NFT ids.
    func loadFavorites() async throws -> Set<String>

    /// Replaces the favorites set with `ids` on the server. Empty `ids` clears the last like through `likes=null`.
    func setFavorites(_ ids: Set<String>) async throws
}
