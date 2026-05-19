import Foundation

/// Запрос с `application/x-www-form-urlencoded` body.
protocol FormEncodedRequest: NetworkRequest {

    /// Поля формы. Значение-массив → повторяющиеся пары `key=v1&key=v2`.
    /// Пустой массив → ключ не отправляется (ограничение mock-сервера).
    var formFields: [String: [String]] { get }
}
