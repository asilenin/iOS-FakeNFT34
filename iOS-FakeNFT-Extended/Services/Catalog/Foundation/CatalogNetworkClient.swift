import Foundation

/// Сетевой клиент Каталога: form-urlencoded запросы шлёт сам,
/// остальные делегирует во `inner`.
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
        NetworkLogger.start(urlRequest)

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkClientError.urlSessionError
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                NetworkLogger.httpError(urlRequest, status: httpResponse.statusCode, body: data)
                throw NetworkClientError.httpStatusCode(httpResponse.statusCode)
            }
            NetworkLogger.success(urlRequest, status: httpResponse.statusCode, byteCount: data.count)
            return data
        } catch {
            NetworkLogger.failure(urlRequest, error: error)
            throw error
        }
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

    /// Сериализует поля в `application/x-www-form-urlencoded` body.
    /// Пустые массивы пропускаются — особенность mock-сервера, см. `FormEncodedRequest`.
    private static func encodeFormFields(_ fields: [String: [String]]) -> Data? {
        let allowed = formURLAllowedCharacters
        var pairs: [String] = []
        for (key, values) in fields where !values.isEmpty {
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            for value in values {
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                pairs.append("\(encodedKey)=\(encodedValue)")
            }
        }
        guard !pairs.isEmpty else { return nil }
        return pairs.joined(separator: "&").data(using: .utf8)
    }

    /// `.urlQueryAllowed` минус `&=+` — эти символы в form body разделители.
    private static let formURLAllowedCharacters: CharacterSet = {
        var set = CharacterSet.urlQueryAllowed
        set.remove(charactersIn: "&=+")
        return set
    }()
}
