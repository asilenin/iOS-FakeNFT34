import Foundation

/// POST оформления заказа (form-urlencoded).
/// Переносит nfts заказа в `profile.nfts` (накопительно) — «выполнение заказа».
/// Эндпоинт описан в API.html как POST /orders/1.
struct OrderPaymentRequest: FormEncodedRequest {

    private enum Field {
        static let nfts = "nfts"
    }

    let nfts: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .post }

    var formFields: [String: [String]] {
        [Field.nfts: nfts]
    }
}
