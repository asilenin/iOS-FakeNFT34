import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkRequestBody {
    case json(Encodable)
    case formURLEncoded([URLQueryItem])
}

protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Encodable? { get }
    var body: NetworkRequestBody? { get }
}

extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Encodable? { nil }
    var body: NetworkRequestBody? {
        guard let dto else { return nil }
        return .json(dto)
    }
}
