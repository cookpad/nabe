import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol Request {
    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var body: [String: Any] { get }
    var header: [String: Any] { get }
    var queryParam: [String: Any] { get }
}

public extension Request {
    var method: HTTPMethod { return .get }
    var path: String { return "" }
    var body: [String: Any] { return [:] }
    var header: [String: Any] { return [:] }
    var queryParam: [String: Any] { return [:] }
}

public protocol RequestConstructable : Request {
    func createRequest() -> URLRequest?
}

public extension RequestConstructable {
    func createRequest() -> URLRequest? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { return nil }

        components.path += path

        let query = queryParam.reduce([URLQueryItem]()) { acc , dict in
            var mutable = acc
            mutable.append(URLQueryItem(name: dict.0, value: dict.1 as? String))
            return mutable
        }

        components.queryItems = query

        guard let constructedURL = components.url else { return nil }

        var request = URLRequest(url: constructedURL)
        request.httpMethod = method.rawValue
        if !body.isEmpty {
            if request.httpMethod != HTTPMethod.get.rawValue {
                request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            }
        }

        for (key, value) in header {
            request.addValue(String(describing: value), forHTTPHeaderField: key)
        }

        let interceptor = compose(Nabe.requestInterceptors.map { $0.intercept })
        return interceptor(request)
    }
}
