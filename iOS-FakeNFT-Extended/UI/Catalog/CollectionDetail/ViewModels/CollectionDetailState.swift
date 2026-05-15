import Foundation

/// Состояние загрузки экрана коллекции NFT.
///
/// Отслеживает статус параллельной загрузки автора и списка NFT с сервера.
/// Данные NFT хранятся отдельно в `CollectionDetailViewModel`
/// для разделения ответственности между состоянием и данными.
/// Автор не участвует в состоянии загрузки — он собирается из `NftCollection` синхронно.
enum CollectionDetailState {
    /// Идёт параллельная загрузка автора и NFT.
    case loading

    /// Автор и NFT успешно загружены.
    case success

    /// Произошла ошибка при загрузке; детали доступны в `CollectionDetailViewModel.error`.
    case error
}
