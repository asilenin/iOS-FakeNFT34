import Foundation

/// Тестовая ошибка для проверки error-сценариев в ViewModel-тестах.
///
/// Использовать там, где конкретный тип ошибки не важен — важен сам факт
/// возникновения. Для тестов сетевого слоя предпочтительнее `NetworkClientError`.
struct TestError: Error, Equatable {
    let message: String
}
