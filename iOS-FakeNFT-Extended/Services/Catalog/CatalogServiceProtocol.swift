import Foundation

protocol CatalogServiceProtocol: Sendable {
    func loadCollections() async throws -> [NftCollection]
}
