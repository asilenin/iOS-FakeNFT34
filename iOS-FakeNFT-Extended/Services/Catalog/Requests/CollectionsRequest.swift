import Foundation

/// GET списка коллекций с опциональной серверной сортировкой.
struct CollectionsRequest: NetworkRequest {

    /// `"name"` | `"nfts"` | `nil` (без сортировки). Значения определяются mock-сервером.
    let sortBy: String?

    /// `1000` по дефолту — все коллекции одним запросом, клиентская пагинация не нужна.
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
