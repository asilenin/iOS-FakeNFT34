import Foundation

/// Конфигурация ячейки `NftGridCell` — данные NFT и UI-состояние.
///
/// Разделение модели и действий упрощает масштабирование компонента
/// при увеличении числа состояний и переиспользовании ячейки
/// в разных контекстах (каталог, избранное, профиль автора и т.д.).
struct NftGridCellConfiguration: Sendable, Equatable {
    let nft: Nft
    let isFavorite: Bool
    let isInCart: Bool

    /// Когда `true` — кнопка избранного дизейблится визуально и не реагирует на тапы.
    /// Используется, чтобы заблокировать действия пользователя, пока:
    /// - идёт PUT-запрос изменения лайка для этого NFT (защита от двойных тапов);
    /// - не удалось загрузить начальный набор лайков (защита от затирания серверного состояния).
    var isFavoriteDisabled: Bool = false

    /// Когда `true` — кнопка корзины дизейблится визуально и не реагирует на тапы.
    /// Применяется по тем же причинам, что и `isFavoriteDisabled`:
    /// - идёт PUT-запрос для этого NFT;
    /// - не удалось загрузить начальный состав корзины.
    var isCartDisabled: Bool = false
}

/// Действия пользователя над ячейкой `NftGridCell`.
///
/// Объединение callback'ов в отдельный тип:
/// - упрощает init ячейки;
/// - позволяет передавать набор действий как единую сущность;
/// - облегчает мокирование в тестах и Preview.
struct NftGridCellActions {
    let onFavoriteTap: () -> Void
    let onCartTap: () -> Void
    let onCellTap: () -> Void

    /// Заглушка для Preview и тестов — все действия no-op.
    static let preview = NftGridCellActions(
        onFavoriteTap: {},
        onCartTap: {},
        onCellTap: {}
    )
}
