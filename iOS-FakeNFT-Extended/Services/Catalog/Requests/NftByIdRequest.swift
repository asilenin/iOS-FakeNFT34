import Foundation

/// Запрос на получение одного NFT по идентификатору.
///
/// Соответствует GET `/api/v1/nft/{id}` mock-сервера Practicum.
/// Используется в `CollectionDetailService` для параллельной загрузки NFT,
/// входящих в коллекцию.
struct NftByIdRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }
}
