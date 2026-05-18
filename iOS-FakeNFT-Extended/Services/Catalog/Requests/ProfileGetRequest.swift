import Foundation

/// Запрос на получение профиля пользователя.
///
/// Соответствует GET `/api/v1/profile/1` mock-сервера Practicum.
/// Используется `CatalogFavoritesService` для загрузки текущего набора лайков.
struct ProfileGetRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
}
