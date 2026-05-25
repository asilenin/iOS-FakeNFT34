import Foundation

/// PUT лайков профиля (form-urlencoded). Заменяет всё множество целиком.
///
/// **Ограничение mock-сервера:** для очистки последнего лайка отправляем
/// `likes=null`, иначе пустой массив будет пропущен form-encoder'ом.
struct ProfileSetLikesRequest: FormEncodedRequest {

    private enum Field {
        static let likes = "likes"
        static let emptyArrayValue = "null"
    }

    let likes: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod { .put }

    var formFields: [String: [String]] {
        [Field.likes: likes.isEmpty ? [Field.emptyArrayValue] : likes]
    }
}
