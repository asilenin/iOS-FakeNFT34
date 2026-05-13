import Foundation

/// Состояние загрузки экрана коллекции NFT.
///
/// Отслеживает статус параллельной загрузки автора и списка NFT с сервера.
/// Данные (автор, NFT) хранятся отдельно в `CollectionDetailViewModel`
/// для разделения ответственности между состоянием и данными.
enum CollectionDetailState {
    /// Идёт параллельная загрузка автора и NFT.
    case loading

    /// Автор и NFT успешно загружены.
    case success

    /// Произошла ошибка при загрузке; детали доступны в `CollectionDetailViewModel.error`.
    case error
}
