import Foundation

/// DTO заказа для эпика Каталога. Независим от модели эпика Корзины.
struct CatalogOrderDto: Decodable {

    /// Идентификатор заказа.
    let id: String

    /// ID NFT в корзине.
    let nfts: [String]
}
