import Foundation

/// PUT состава корзины (form-urlencoded). Заменяет всё множество целиком.
///
/// **Ограничение mock-сервера:** пустой массив `nfts` ведёт к ошибке
/// `entity by id is missing`. `CatalogNetworkClient` пропустит пустой массив,
/// и запрос станет no-op — удалить последний NFT через PUT нельзя.
/// После `invalidateCache` + `loadCart` на сервере останется предыдущий состав.
struct OrderSetNftsRequest: FormEncodedRequest {

    private enum Field {
        static let nfts = "nfts"
    }

    let nfts: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .put }

    var formFields: [String: [String]] {
        [Field.nfts: nfts]
    }
}
