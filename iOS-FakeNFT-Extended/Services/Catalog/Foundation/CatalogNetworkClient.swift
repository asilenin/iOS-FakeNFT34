import Foundation

/// Сетевой клиент эпика Каталога, поддерживающий form-urlencoded body
/// дополнительно к стандартным JSON-запросам.
///
/// Архитектура — композиция:
/// - JSON и no-body запросы делегируются во вложенный `inner: NetworkClient`
///   (обычно `DefaultNetworkClient`), чтобы не дублировать общую логику.
/// - Form-encoded запросы (`FormEncodedRequest`) обрабатываются здесь
///   напрямую через `URLSession` — это единственный кусок логики, который
///   нельзя реализовать через общий `DefaultNetworkClient` без его модификации.
///
/// Используется в `CatalogFavoritesService` и `CatalogCartService` для PUT.
/// `CatalogService` и `CollectionDetailService` могут использовать обычный
/// `DefaultNetworkClient` — им form-encoded не нужен.
actor CatalogNetworkClient: NetworkClient {

    private let inner: NetworkClient
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        inner: NetworkClient,
        session: URLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.inner = inner
        self.session = session
        self.decoder = decoder
    }

    func send(request: NetworkRequest) async throws -> Data {
        if let formRequest = request as? FormEncodedRequest {
            return try await sendFormEncoded(formRequest)
        }
        return try await inner.send(request: request)
    }

    func send<T: Decodable>(request: NetworkRequest) async throws -> T {
        let data = try await send(request: request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkClientError.parsingError
        }
    }

    // MARK: - Private

    private func sendFormEncoded(_ request: FormEncodedRequest) async throws -> Data {
        let urlRequest = try buildFormEncodedURLRequest(from: request)
        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkClientError.urlSessionError
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkClientError.httpStatusCode(httpResponse.statusCode)
        }
        return data
    }

    private func buildFormEncodedURLRequest(from request: FormEncodedRequest) throws -> URLRequest {
        guard let endpoint = request.endpoint else {
            throw NetworkClientError.incorrectRequest("Empty endpoint")
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        urlRequest.addValue(
            RequestConstants.token,
            forHTTPHeaderField: "X-Practicum-Mobile-Token"
        )
        urlRequest.httpBody = Self.encodeFormFields(request.formFields)
        return urlRequest
    }

    /// Сериализует словарь полей в form URL-encoded body.
    ///
    /// **Пустые массивы пропускаются** — это вынужденное поведение из-за
    /// специфики mock-сервера FakeNFT: `likes=` (пустая строка) трактуется
    /// сервером как массив с одним элементом-пустой-строкой, и валится
    /// с `entity by id is missing`.
    ///
    /// Известное ограничение: невозможно «сбросить лайки в пустой массив»
    /// одним запросом — сервер не принимает такой формат. Если все массивы
    /// пустые, body будет пустой строкой и запрос будет no-op для сервера.
    private static func encodeFormFields(_ fields: [String: [String]]) -> Data? {
        var components = URLComponents()
        var items: [URLQueryItem] = []
        for (key, values) in fields where !values.isEmpty {
            for value in values {
                items.append(URLQueryItem(name: key, value: value))
            }
        }
        components.queryItems = items
        return components.query?.data(using: .utf8)
    }
}
