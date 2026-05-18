import Foundation

/// Запрос на установку списка лайков пользователя.
///
/// Соответствует PUT `/api/v1/profile/1` с `Content-Type: application/x-www-form-urlencoded`.
/// Тело: `likes=id1&likes=id2&...` для каждого id.
///
/// Сервер заменяет полное множество лайков переданным значением.
/// Поля профиля, отсутствующие в теле (`name`, `avatar`, etc.), сервер сохраняет
/// без изменений.
///
/// **Ограничение mock-сервера:** пустой массив `likes` ведёт к ошибке
/// `entity by id is missing`, поэтому сбросить лайки в пустой набор одним
/// PUT-запросом невозможно. `CatalogNetworkClient` пропустит пустые массивы
/// в body, что эквивалентно no-op запросу.
struct ProfileSetLikesRequest: FormEncodedRequest {

    private enum Field {
        static let likes = "likes"
    }

    let likes: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod { .put }

    var formFields: [String: [String]] {
        [Field.likes: likes]
    }
}
