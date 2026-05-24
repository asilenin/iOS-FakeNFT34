import Foundation

/// PUT состава корзины (form-urlencoded). Заменяет всё множество целиком.
///
/// **Ограничение mock-сервера:** для очистки корзины отправляем `nfts=null`,
/// иначе пустой массив даёт ошибку `entity by id is missing` (аналогично
/// `ProfileSetLikesRequest` с `likes=null`).
struct OrderSetNftsRequest: FormEncodedRequest {

    private enum Field {
        static let nfts = "nfts"
        static let emptyArrayValue = "null"
    }

    let nfts: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .put }

    var formFields: [String: [String]] {
        [Field.nfts: nfts.isEmpty ? [Field.emptyArrayValue] : nfts]
    }
}
