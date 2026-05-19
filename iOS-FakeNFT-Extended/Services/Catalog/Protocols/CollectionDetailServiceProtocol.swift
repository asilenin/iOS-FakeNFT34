import Foundation

/// Сервис загрузки NFT для коллекции.
protocol CollectionDetailServiceProtocol: Sendable {

    /// Загружает NFT по списку id. Дубликаты дедуплицируются.
    ///
    /// **Best-effort**: возвращает только успешно загруженные NFT.
    /// Бросает ошибку, только если ни один запрос не успешен.
    /// Порядок результата не гарантируется.
    func loadNfts(byIds ids: [String]) async throws -> [Nft]

    /// Сбрасывает кэш.
    func invalidateCache() async
}
