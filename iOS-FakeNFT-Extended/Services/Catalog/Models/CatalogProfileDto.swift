import Foundation

/// DTO профиля для эпика Каталога. Независим от модели эпика Профиля.
struct CatalogProfileDto: Decodable {

    /// Идентификатор профиля.
    let id: String

    /// ID избранных NFT.
    let likes: [String]
}
