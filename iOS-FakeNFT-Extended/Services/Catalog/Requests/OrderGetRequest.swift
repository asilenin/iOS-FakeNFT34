import Foundation

/// Запрос на получение корзины пользователя.
///
/// Соответствует GET `/api/v1/orders/1` mock-сервера Practicum.
/// Используется `CatalogCartService` для загрузки текущего состава корзины.
struct OrderGetRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}
