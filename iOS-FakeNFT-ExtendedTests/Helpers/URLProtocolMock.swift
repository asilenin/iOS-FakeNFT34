import Foundation

/// `URLProtocol` subclass для перехвата HTTP-запросов в тестах.
///
/// Регистрируется в `URLSessionConfiguration.protocolClasses` и позволяет
/// тестам инспектировать исходящие `URLRequest` (URL, headers, body)
/// и подсовывать заранее заготовленные `URLResponse` + `Data` или ошибки.
///
/// Использование:
/// ```swift
/// let config = URLSessionConfiguration.ephemeral
/// config.protocolClasses = [URLProtocolMock.self]
/// let session = URLSession(configuration: config)
/// URLProtocolMock.responseHandler = { request in
///     return (HTTPURLResponse(...), Data(...))
/// }
/// ```
///
/// **Thread-safety:** `responseHandler` и `interceptedRequests` доступны
/// только с одного потока в каждом тесте — обнуляются между тестами в setUp/tearDown.
final class URLProtocolMock: URLProtocol {

    /// Хендлер, который возвращает (HTTPURLResponse, Data) или бросает Error.
    /// Устанавливается каждым тестом перед запросом.
    nonisolated(unsafe) static var responseHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    /// Все перехваченные запросы в порядке поступления.
    /// Тесты читают это после `await session.data(for:)` для assertion'ов.
    nonisolated(unsafe) static var interceptedRequests: [URLRequest] = []

    static func reset() {
        responseHandler = nil
        interceptedRequests = []
    }

    // swiftlint:disable static_over_final_class
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    // swiftlint:enable static_over_final_class

    override func startLoading() {
        // URLSession не передаёт httpBody в URLRequest, который попадает в URLProtocol.
        // Body доступен через `httpBodyStream`. Восстанавливаем в URLRequest вручную.
        var requestForLog = request
        if requestForLog.httpBody == nil, let stream = request.httpBodyStream {
            requestForLog.httpBody = Self.readData(from: stream)
        }
        Self.interceptedRequests.append(requestForLog)

        guard let handler = Self.responseHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(requestForLog)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    private static func readData(from stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read > 0 {
                data.append(buffer, count: read)
            } else {
                break
            }
        }
        return data
    }
}
