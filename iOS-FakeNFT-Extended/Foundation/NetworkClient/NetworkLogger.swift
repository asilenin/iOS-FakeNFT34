import Foundation

/// Централизованное логирование сетевых запросов. Активно только в DEBUG.
enum NetworkLogger {

    static func start(_ request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "?"
        let url = request.url?.absoluteString ?? "nil"
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8),
           !bodyString.isEmpty {
            print("→ \(method) \(url)  body: \(bodyString)")
        } else {
            print("→ \(method) \(url)")
        }
        #endif
    }

    static func success(_ request: URLRequest, status: Int, byteCount: Int) {
        #if DEBUG
        print("← \(status) \(request.url?.absoluteString ?? "nil")  (\(byteCount) bytes)")
        #endif
    }

    static func httpError(_ request: URLRequest, status: Int, body: Data) {
        #if DEBUG
        print("✗ \(status) \(request.url?.absoluteString ?? "nil")  \(String(data: body, encoding: .utf8) ?? "")")
        #endif
    }

    static func failure(_ request: URLRequest, error: Error) {
        #if DEBUG
        print("✗ error \(request.url?.absoluteString ?? "nil")  \(error)")
        #endif
    }
}
