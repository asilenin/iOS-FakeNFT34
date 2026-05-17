import Foundation

/// Протокол для загрузки каталога коллекций.
///
/// Реализуется как `actor`, безопасен для конкурентного доступа.
protocol CatalogServiceProtocol: Sendable {

    /// Загружает список коллекций, опционально отсортированных сервером.
    ///
    /// - Parameter sortBy: Опция сортировки. `nil` — без сортировки
    ///   (сервер вернёт в дефолтном порядке).
    /// - Returns: Массив коллекций.
    /// - Throws: Сетевая или парсинг-ошибка.
    func loadCollections(sortBy: CatalogSortOption?) async throws -> [NftCollection]

    /// Сбрасывает внутренний кэш. Вызывается из ViewModel при pull-to-refresh,
    /// чтобы следующий `loadCollections` гарантированно сделал сетевой запрос.
    func invalidateCache() async
}
