import Foundation

protocol FavoritesServiceProtocol: Sendable {

    /// Fetches the current set of liked NFT ids.
    func loadFavorites() async throws -> Set<String>

    /// Replaces the favorites set with `ids` on the server. The implementation must send the full set in a single PUT.
    func setFavorites(_ ids: Set<String>) async throws
}
