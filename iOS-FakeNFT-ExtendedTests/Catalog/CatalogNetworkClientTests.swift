import XCTest
@testable import iOS_FakeNFT_Extended

final class CatalogNetworkClientTests: XCTestCase {

    private var inner: MockNetworkClient!
    private var session: URLSession!
    private var client: CatalogNetworkClient!

    override func setUp() {
        super.setUp()
        URLProtocolMock.reset()
        inner = MockNetworkClient()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: config)
        client = CatalogNetworkClient(inner: inner, session: session)
    }

    override func tearDown() {
        client = nil
        session = nil
        inner = nil
        URLProtocolMock.reset()
        super.tearDown()
    }

    // MARK: - Test fixtures

    private struct PlainGetRequest: NetworkRequest {
        var endpoint: URL? { URL(string: "https://example.test/api/v1/things") }
    }

    private struct LikesPutRequest: FormEncodedRequest {
        let likes: [String]
        var endpoint: URL? { URL(string: "https://example.test/api/v1/profile/1") }
        var httpMethod: HttpMethod { .put }
        var formFields: [String: [String]] { ["likes": likes] }
    }

    private struct MultiFieldRequest: FormEncodedRequest {
        let likes: [String]
        let extras: [String]
        var endpoint: URL? { URL(string: "https://example.test/api/v1/profile/1") }
        var httpMethod: HttpMethod { .put }
        var formFields: [String: [String]] { ["likes": likes, "extras": extras] }
    }

    private static func okResponse(for url: URL, body: String = "{}") -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (response, body.data(using: .utf8)!)
    }

    // MARK: - Tests: delegation

    func test_plainGetRequest_delegatesToInnerClient() async throws {
        let request = PlainGetRequest()
        await inner.stub(url: request.endpoint!.absoluteString, data: Data("[]".utf8))

        _ = try await client.send(request: request)

        let innerCalls = await inner.totalCalls
        XCTAssertEqual(innerCalls, 1)
        XCTAssertTrue(URLProtocolMock.interceptedRequests.isEmpty,
                      "Plain request must not bypass inner client to URLSession")
    }

    // MARK: - Tests: form-encoded body

    func test_singleFormField_singleValue_encodesAsKeyValuePair() async throws {
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!)
        }

        _ = try await client.send(request: LikesPutRequest(likes: ["id-1"]))

        let intercepted = URLProtocolMock.interceptedRequests.first
        XCTAssertEqual(intercepted?.httpBody, Data("likes=id-1".utf8))
        XCTAssertEqual(intercepted?.value(forHTTPHeaderField: "Content-Type"),
                       "application/x-www-form-urlencoded")
    }

    func test_singleFormField_multipleValues_encodesAsRepeatedKeys() async throws {
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!)
        }

        _ = try await client.send(request: LikesPutRequest(likes: ["id-1", "id-2"]))

        let body = URLProtocolMock.interceptedRequests.first?.httpBody.flatMap {
            String(data: $0, encoding: .utf8)
        }
        XCTAssertEqual(body, "likes=id-1&likes=id-2")
    }

    func test_emptyArray_isOmittedFromBody() async throws {
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!)
        }

        _ = try await client.send(request: LikesPutRequest(likes: []))

        let body = URLProtocolMock.interceptedRequests.first?.httpBody.flatMap {
            String(data: $0, encoding: .utf8)
        }
        // Пустые массивы пропускаются → body пустое (URLComponents.query == nil → Data?  пустая).
        XCTAssertTrue(body == "" || body == nil,
                      "Empty arrays must not produce `key=` pair; got: \(String(describing: body))")
    }

    func test_multipleFieldsWithEmptyOne_onlyNonEmptyFieldsAreEncoded() async throws {
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!)
        }

        _ = try await client.send(request: MultiFieldRequest(likes: ["x"], extras: []))

        let body = URLProtocolMock.interceptedRequests.first?.httpBody.flatMap {
            String(data: $0, encoding: .utf8)
        }
        XCTAssertEqual(body, "likes=x", "Empty `extras` array must not appear in body")
    }

    func test_specialCharactersInValues_arePercentEncoded() async throws {
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!)
        }

        _ = try await client.send(request: LikesPutRequest(likes: ["a&b=c"]))

        let body = URLProtocolMock.interceptedRequests.first?.httpBody.flatMap {
            String(data: $0, encoding: .utf8)
        }
        // URLComponents должен экранировать `&` и `=` в значении.
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("a%26b%3Dc"),
                      "Special chars must be percent-encoded; got body: \(body!)")
    }

    // MARK: - Tests: headers and method

    func test_formEncodedRequest_setsAuthTokenHeader() async throws {
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!)
        }

        _ = try await client.send(request: LikesPutRequest(likes: ["x"]))

        let token = URLProtocolMock.interceptedRequests.first?
            .value(forHTTPHeaderField: "X-Practicum-Mobile-Token")
        XCTAssertEqual(token, RequestConstants.token)
    }

    func test_formEncodedRequest_setsHttpMethod() async throws {
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!)
        }

        _ = try await client.send(request: LikesPutRequest(likes: ["x"]))

        XCTAssertEqual(URLProtocolMock.interceptedRequests.first?.httpMethod, "PUT")
    }

    // MARK: - Tests: error handling

    func test_formEncoded_non2xxResponse_throwsHttpStatusCode() async {
        URLProtocolMock.responseHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            _ = try await client.send(request: LikesPutRequest(likes: ["x"]))
            XCTFail("Expected error for 500 status")
        } catch let NetworkClientError.httpStatusCode(code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Expected httpStatusCode error, got \(error)")
        }
    }

    func test_formEncoded_decodesJsonResponse() async throws {
        struct Response: Decodable, Equatable {
            let likes: [String]
        }
        URLProtocolMock.responseHandler = { request in
            Self.okResponse(for: request.url!, body: #"{"likes":["a","b"]}"#)
        }

        let response: Response = try await client.send(request: LikesPutRequest(likes: ["a", "b"]))

        XCTAssertEqual(response, Response(likes: ["a", "b"]))
    }
}
