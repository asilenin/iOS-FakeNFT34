import Foundation
@testable import iOS_FakeNFT_Extended

/// Программируемый mock `NetworkClient` для unit-тестов сервисов.
///
/// Хранит ответы (JSON `Data` или `Error`) пер-URL.
/// Real-style decoding: метод `send<T>` использует `JSONDecoder` так же, как и `DefaultNetworkClient` —
/// поэтому тесты заодно проверяют корректность Decodable-моделей.
///
/// История вызовов (`callLog`) и счётчик per-URL (`callCount(for:)`)
/// позволяют проверять дедупликацию, кэширование и порядок запросов.
actor MockNetworkClient: NetworkClient {

    // MARK: - Programmable responses

    /// Заготовленные ответы по URL endpoint. Совпадение — по строковому виду URL.
    private var responses: [String: Result<Data, Error>] = [:]

    /// Дефолтный ответ для URL, не присутствующих в `responses`.
    /// Если `nil` — для незаданного URL метод бросает `incorrectRequest`.
    private var defaultResponse: Result<Data, Error>?

    // MARK: - Call log

    /// Все вызовы `send` в порядке поступления.
    private(set) var callLog: [String] = []

    private let decoder: JSONDecoder

    // MARK: - Init

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    // MARK: - Configuration

    /// Запрограммировать ответ JSON-данными для указанного URL.
    func stub(url: String, data: Data) {
        responses[url] = .success(data)
    }

    /// Запрограммировать ответ JSON-данными, закодированными из Encodable-объекта.
    func stub<T: Encodable>(url: String, encodable: T) throws {
        let data = try JSONEncoder().encode(encodable)
        responses[url] = .success(data)
    }

    /// Запрограммировать ошибку для указанного URL.
    func stub(url: String, error: Error) {
        responses[url] = .failure(error)
    }

    /// Установить дефолтный ответ для URL, отсутствующих в `responses`.
    func setDefaultResponse(_ result: Result<Data, Error>) {
        defaultResponse = result
    }

    // MARK: - Inspection

    /// Сколько раз была дёрнута сеть для указанного URL.
    func callCount(for url: String) -> Int {
        callLog.filter { $0 == url }.count
    }

    /// Сколько всего было сетевых вызовов.
    var totalCalls: Int {
        callLog.count
    }

    // MARK: - NetworkClient

    func send(request: NetworkRequest) async throws -> Data {
        guard let url = request.endpoint?.absoluteString else {
            throw NetworkClientError.incorrectRequest("Empty endpoint")
        }
        callLog.append(url)

        let result = responses[url] ?? defaultResponse
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        case .none:
            throw NetworkClientError.incorrectRequest("No stub for URL: \(url)")
        }
    }

    func send<T: Decodable>(request: NetworkRequest) async throws -> T {
        let data = try await send(request: request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkClientError.parsingError
        }
    }
}
