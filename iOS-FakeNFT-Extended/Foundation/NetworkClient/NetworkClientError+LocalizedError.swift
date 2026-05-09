import Foundation

extension NetworkClientError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .httpStatusCode, .urlSessionError, .urlRequestError:
            return NSLocalizedString("Error.network", comment: "")
        case .parsingError:
            return NSLocalizedString("Error.parsing", comment: "")
        case .incorrectRequest:
            return NSLocalizedString("Error.network", comment: "")
        }
    }
}
