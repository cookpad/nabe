import Foundation

public struct RequestError: Error {
    enum ErrorKind: Int {
        case invalid = -1001

        case badRequest = 400,
        unauthorized = 401,
        forbidden = 403,
        notFound = 404,
        methodNotAllowed = 405,
        notAcceptable = 406,
        proxyAuthenticationRequired = 407,
        requestTimeout = 408,
        conflict = 409,
        gone = 410,
        lengthRequired = 411,
        preconditionFailed = 412,
        requestEntityTooLarge = 413,
        requestURITooLong = 414,
        unsupportedMediaType = 415

        case internalServerError = 500,
        notImplemented = 501,
        badGateway = 502,
        serviceUnavailable = 503,
        gatewayTimeout = 504,
        httpVersionNotSupported = 505

        case deserialization = 999

        case unknown = -1

        var description: String {
            switch self {
            case .invalid:
                return "Invalid request"
            case .badRequest:
                return "Bad request"
            case .unauthorized:
                return "Unauthorized"
            case .forbidden:
                return "Forbidden"
            case .notAcceptable:
                return "Not acceptable"
            case .proxyAuthenticationRequired:
                return "Proxy authentication required"
            case .requestTimeout:
                return "Request timeout"
            case .conflict:
                return "Conflict"
            case .gone:
                return "Gone"
            case .lengthRequired:
                return "Length Required"
            case .preconditionFailed:
                return "Precondition failed"
            case .requestEntityTooLarge:
                return "Request entity too large"
            case .requestURITooLong:
                return "Request URI too long"
            case .unsupportedMediaType:
                return "Unsupported media type"
            case .internalServerError:
                return "Internal Server Error"
            case .notImplemented:
                return "Not implemented"
            case .badGateway:
                return "Bad gateway"
            case .serviceUnavailable:
                return "Service unavailable"
            case .gatewayTimeout:
                return "Gateway timeout"
            case .httpVersionNotSupported:
                return "HTTP Version not supported"
            default:
                return "Unknown"
            }
        }
    }

    let kind: ErrorKind
    let data: Data?

    func deserializeData<T: Deserializable, U>(with deserializer: T) -> U? where U == T.T {
        guard let data = data else { return nil }
        return deserializer.deserialize(data)
    }
}

extension RequestError : CustomStringConvertible {
    public var description: String {
        var results = [String]()
        results.append("[Error] : \(kind.description)")
        results.append("[Data] : \(data == nil ? "<no data>" : String(data: data!, encoding: .utf8))")
        return results.joined(separator: "\n")
    }
}
