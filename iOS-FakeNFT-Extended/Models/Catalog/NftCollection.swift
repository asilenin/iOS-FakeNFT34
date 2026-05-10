import Foundation

struct NftCollection: Sendable, Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let cover: URL
    let nfts: [String]
    let description: String
    let author: String
    let website: URL
    let createdAt: String
}
