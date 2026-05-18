import Foundation

/// Автор NFT или коллекции.
///
/// UI-модель, собираемая на клиенте из полей NFT (`author`, `website`).
/// Используется в ViewModel и UI для типизированной передачи пары (имя + ссылка).
struct Author: Sendable, Identifiable, Equatable {
    // Уникальный идентификатор автора
    let id: String

    // Имя автора
    let name: String

    // URL сайта/профиля (хранится как строка, конвертируется в URL по месту)
    let website: String
}
