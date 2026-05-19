import Foundation

/// Состояние загрузки каталога. Детали ошибки — в `CatalogViewModel.error`.
enum CatalogState {
    case loading
    case success
    case error
}
