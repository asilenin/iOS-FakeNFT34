import Foundation

/// Протокол для загрузки детальных данных коллекции: NFT и автора.
///
/// Отвечает за асинхронную загрузку списка NFT по идентификаторам
/// и информации об авторе коллекции. Используется в `CollectionDetailViewModel`.
/// Помечен `Sendable` для безопасной передачи между actor-сервисами
/// и `@MainActor` ViewModel.
protocol CollectionDetailServiceProtocol: Sendable {

    /// Загружает список NFT по переданным идентификаторам.
    ///
    /// - Parameter ids: Массив уникальных идентификаторов NFT.
    /// - Returns: Массив загруженных NFT в порядке переданных `ids`.
    ///   Если для какого-то id данных нет, он пропускается.
    /// - Throws: Ошибка при проблемах с загрузкой или парсингом данных.
    func loadNfts(byIds ids: [String]) async throws -> [Nft]

    /// Загружает информацию об авторе коллекции по идентификатору.
    ///
    /// - Parameter id: Уникальный идентификатор автора.
    /// - Returns: Объект `Author` с именем и ссылкой на сайт.
    /// - Throws: Ошибка при проблемах с загрузкой данных.
    func loadAuthor(by id: String) async throws -> Author
}
