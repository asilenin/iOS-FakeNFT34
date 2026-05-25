import Foundation

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
    case incorrectRequest(String)
}

protocol NetworkClient {
    func send(request: NetworkRequest) async throws -> Data
    func send<T: Decodable>(request: NetworkRequest) async throws -> T
}

actor DefaultNetworkClient: NetworkClient {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        session: URLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func send(request: NetworkRequest) async throws -> Data {
            let urlRequest = try create(request: request)
            NetworkLogger.start(urlRequest)

            do {
                let (data, response) = try await session.data(for: urlRequest)

                guard let response = response as? HTTPURLResponse else {
                    throw NetworkClientError.urlSessionError
                }

                guard 200 ..< 300 ~= response.statusCode else {
                    NetworkLogger.httpError(urlRequest, status: response.statusCode, body: data)
                    throw NetworkClientError.httpStatusCode(response.statusCode)
                }

                NetworkLogger.success(urlRequest, status: response.statusCode, byteCount: data.count)
                return data
            } catch let error as NetworkClientError {
                throw error
            } catch {
                NetworkLogger.failure(urlRequest, error: error)
                throw NetworkClientError.urlRequestError(error)
            }
        }

    func send<T: Decodable>(request: NetworkRequest) async throws -> T {
        let data = try await send(request: request)
        return try parse(data: data)
    }

    // MARK: - Private

    private func create(request: NetworkRequest) throws -> URLRequest {
        guard let endpoint = request.endpoint else {
            throw NetworkClientError.incorrectRequest("Empty endpoint")
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue

        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        try configureBody(for: request, urlRequest: &urlRequest)

        return urlRequest
    }

    private func configureBody(
        for request: NetworkRequest,
        urlRequest: inout URLRequest
    ) throws {
        guard let body = request.body else { return }

        switch body {
        case .json(let dto):
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try encoder.encode(dto)

        case .formURLEncoded(let items):
            urlRequest.setValue(
                "application/x-www-form-urlencoded",
                forHTTPHeaderField: "Content-Type"
            )
            urlRequest.httpBody = Self.formURLEncodedData(from: items)
        }
    }

    private static func formURLEncodedData(from items: [URLQueryItem]) -> Data? {
        var components = URLComponents()
        components.queryItems = items
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    private func parse<T: Decodable>(data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            print("❌ Parsing error: \(error)")
            print("❌ Response body: \(responseBody)")
            #endif

            throw NetworkClientError.parsingError
        }
    }
}
