import Foundation

/// Коллекция NFT в каталоге.
///
/// Соответствует ответу `/api/v1/collections` mock-сервера Practicum.
/// Используется как value-объект в каталоге и как payload навигации (`NavigationPath`/`navigationDestination(for:)`), поэтому соответствует `Hashable` и `Identifiable`.
/// Помечена `Sendable` для безопасной передачи между actor-сервисами и `@MainActor` ViewModel.
struct NftCollection: Sendable, Decodable, Identifiable, Hashable {

    /// Уникальный идентификатор коллекции
    let id: String

    /// Название коллекции
    let name: String?

    /// URL обложки коллекции
    let cover: URL?

    /// Список идентификаторов NFT, входящих в коллекцию
    let nfts: [String]?

    /// Описание коллекции
    let description: String?

    /// Автор коллекции
    let author: String?

    /// Сайт коллекции или автора
    let website: URL?

    /// Дата создания коллекции в формате строки, приходящей с backend
    let createdAt: String?
}
