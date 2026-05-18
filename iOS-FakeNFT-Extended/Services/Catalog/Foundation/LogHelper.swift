import Foundation

/// Возвращает имя файла без полного пути для логирования.
///
/// Использование:
/// ```swift
/// print("ℹ️ [\(fileName())]: :\(#line)] \(#function) ...")
/// ```
func fileName(_ path: String = #file) -> String {
    (path as NSString).lastPathComponent
}
