import Foundation

/// Запрос на получение списка коллекций NFT.
///
/// Соответствует GET `/api/v1/collections` mock-сервера Practicum.
/// Параметры пагинации (`page`, `size`, `sortBy`) не передаются — на текущий момент
/// каталогу нужен полный список; пагинация может быть добавлена позже без изменения интерфейса.
struct CollectionsRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
    }
}
