import Foundation

/// Состояние загрузки экрана коллекции. Детали ошибки — в `CollectionDetailViewModel.error`.
enum CollectionDetailState {
    case loading
    case success
    case error
}
