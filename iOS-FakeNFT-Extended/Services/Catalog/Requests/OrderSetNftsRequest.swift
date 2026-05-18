import Foundation

/// Запрос на установку состава корзины пользователя.
///
/// Соответствует PUT `/api/v1/orders/1` с `Content-Type: application/x-www-form-urlencoded`.
/// Тело: `nfts=id1&nfts=id2&...` для каждого id.
///
/// Сервер заменяет полный состав корзины переданным значением.
///
/// **Ограничение mock-сервера:** пустой массив `nfts` ведёт к ошибке
/// `entity by id is missing`. `CatalogNetworkClient` пропускает пустые
/// массивы в body, поэтому удалить последний NFT из корзины через PUT
/// невозможно — последнее обновление будет no-op запросом, на сервере
/// останется предыдущий состав. Это известное ограничение API,
/// в Каталоге пользователь увидит локально пустую корзину, но при
/// следующем `loadCart` без инвалидации кэша состояние совпадёт.
/// При перезагрузке (invalidateCache + load) серверный состав вернётся.
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
