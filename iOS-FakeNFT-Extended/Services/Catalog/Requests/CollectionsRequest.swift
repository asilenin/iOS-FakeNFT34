import Foundation

/// Запрос на получение списка коллекций NFT.
///
/// Соответствует GET `/api/v1/collections` mock-сервера Practicum.
/// Поддерживает серверную сортировку через query-параметр `sortBy`
/// и явный размер страницы `size`.
struct CollectionsRequest: NetworkRequest {

    /// Ключ серверной сортировки. Известные значения для mock-сервера:
    /// - `"name"` — по названию коллекции (А-Я),
    /// - `"nfts"` — по количеству NFT (по убыванию).
    /// `nil` — без сортировки (сервер вернёт в дефолтном порядке).
    let sortBy: String?

    /// Размер страницы. `1000` гарантирует получение всех коллекций
    /// одним запросом — на mock-сервере их всего несколько штук,
    /// клиентская пагинация не требуется.
    let size: Int

    init(sortBy: String? = nil, size: Int = 1000) {
        self.sortBy = sortBy
        self.size = size
    }

    var endpoint: URL? {
        var components = URLComponents(string: "\(RequestConstants.baseURL)/api/v1/collections")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "size", value: String(size))
        ]
        if let sortBy {
            queryItems.append(URLQueryItem(name: "sortBy", value: sortBy))
        }
        components?.queryItems = queryItems
        return components?.url
    }
}
