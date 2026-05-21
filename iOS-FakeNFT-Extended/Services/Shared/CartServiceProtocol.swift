import Foundation

protocol CartServiceProtocol: Sendable {

    /// Fetches the current set of NFT ids in the cart.
    func loadCart() async throws -> Set<String>

    /// Replaces the cart contents with `ids` on the server. The implementation must send the full set in a single PUT.
    func setCart(_ ids: Set<String>) async throws

    func loadCartItems() async throws -> [CartItem]
}
