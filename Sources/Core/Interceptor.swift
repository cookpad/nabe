import Foundation

public protocol RequestInterceptor {
    func intercept(request: URLRequest) -> URLRequest
}

public protocol ResponseInterceptor {
    func intercept(response: HTTPURLResponse) -> HTTPURLResponse
}

public struct CURLRequestInterceptor : RequestInterceptor {
    var tag: String

    public init(tag: String) {
        self.tag = tag
    }

    public init() {
        tag = "CURLRequestInterceptor"
    }

    public func intercept(request: URLRequest) -> URLRequest {
        print("\(tag) --> \n \(convertURLRequestToCurlCommand(request))")
        return request
    }
}

func convertURLRequestToCurlCommand(_ request: URLRequest) -> String {
    let method = request.httpMethod ?? "GET"
    var returnValue = "curl -X \(method) \\"

    if let httpBody = request.httpBody, request.httpMethod == "POST" {
        let maybeBody = String(data: httpBody, encoding: String.Encoding.utf8)
        if let body = maybeBody {
            returnValue += "-d \"\(body.replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil))\" "
        }
    }

    for (key, value) in request.allHTTPHeaderFields ?? [:] {
        let escapedKey = (key as String).replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil)
        let escapedValue = (value as String).replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil)
        returnValue += "\n    -H \"\(escapedKey): \(escapedValue)\" "
    }

    let URLString = request.url?.absoluteString ?? "<unknown url>"

    returnValue += "\n\"\(URLString.replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil))\""

    returnValue += " -i -v"

    return returnValue
}
