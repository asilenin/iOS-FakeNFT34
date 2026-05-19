import Foundation

/// PUT лайков профиля (form-urlencoded). Заменяет всё множество целиком.
///
/// **Ограничение mock-сервера:** пустой массив `likes` ведёт к ошибке
/// `entity by id is missing`. `CatalogNetworkClient` пропустит пустой массив,
/// и запрос станет no-op — сбросить лайки в пустой набор одним PUT нельзя.
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
