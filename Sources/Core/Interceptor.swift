import Foundation

public protocol RequestInterceptor {
    func intercept(request: URLRequest?) -> URLRequest?
}

public protocol ResponseInterceptor {
    func intercept(meta: (Data?, HTTPURLResponse)) -> (Data?, HTTPURLResponse)
}

public struct CURLRequestInterceptor : RequestInterceptor {
    let tag: String

    public init(tag: String) {
        self.tag = tag
    }

    public init() {
        tag = "CURLRequestInterceptor"
    }

    public func intercept(request: URLRequest?) -> URLRequest? {
        guard let request = request else { return nil }
        print("\(tag) --> \n \(convertURLRequestToCurlCommand(request))")
        return request
    }
}

fileprivate func convertURLRequestToCurlCommand(_ request: URLRequest) -> String {
    let method = request.httpMethod ?? "GET"
    var returnValue = "curl -X \(method)"

    if let httpBody = request.httpBody, request.httpMethod == "POST" {
        let maybeBody = String(data: httpBody, encoding: String.Encoding.utf8)
        if let body = maybeBody {
            returnValue += " -d \"\(body.replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil))\""
        }
    }

    for (key, value) in request.allHTTPHeaderFields ?? [:] {
        let escapedKey = (key as String).replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil)
        let escapedValue = (value as String).replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil)
        returnValue += " -H \"\(escapedKey): \(escapedValue)\""
    }

    let URLString = request.url?.absoluteString ?? "<unknown url>"

    returnValue += " \"\(URLString.replacingOccurrences(of: "\"", with: "\\\"", options:[], range: nil))\" -i -v"

    return returnValue
}

public struct StringResponseInterceptor : ResponseInterceptor {
    let tag: String
    
    public init(tag: String) {
        self.tag = tag
    }

    public init() {
        tag = "StringResponseInterceptor"
    }
    
    public func intercept(meta: (Data?, HTTPURLResponse)) -> (Data?, HTTPURLResponse) {
        if let data = meta.0 {
            print("\(tag) <-- \n \(String(data: data, encoding: .utf8) ?? "")")
        } else {
            print("\(tag) <-- \n <no data>")
        }
        return meta
    }
}
