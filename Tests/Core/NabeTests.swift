import XCTest
@testable import Nabe

class NabeTests: XCTestCase {

    override static func setUp() {
        Nabe.requestInterceptors.append(CURLRequestInterceptor(tag: "CURL"))
        Nabe.responseInterceptors.append(StringResponseInterceptor(tag: "Response"))
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testHTTPBinGet() {
        wait { exp in
            HTTPBin.Get().call { result, response in
                switch result {
                case .success:
                    XCTAssert(true)
                case .failure:
                    XCTAssert(false)
                }
                exp.fulfill()
            }
        }
    }

    func testHTTPBinPost() {
        wait { exp in
            HTTPBin.Post().call { result, response in
                switch result {
                case .success:
                    XCTAssert(true)
                case .failure:
                    XCTAssert(false)
                }
                exp.fulfill()
            }
        }
    }

    func testHTTPBinPut() {
        wait { exp in
            HTTPBin.Put().call { result, response in
                switch result {
                case .success:
                    XCTAssert(true)
                case .failure:
                    XCTAssert(false)
                }
                exp.fulfill()
            }
        }
    }

    func testHTTPBinDelete() {
        wait { exp in
            HTTPBin.Delete().call { result, response in
                switch result {
                case .success:
                    XCTAssert(true)
                case .failure:
                    XCTAssert(false)
                }
                exp.fulfill()
            }
        }
    }

    func testCustomHTTPStatus() {
        let status412 = HTTPBin.Status(code: 412)
        wait { exp in
            status412.call { result, response in
                switch result {
                case .success:
                    XCTAssert(false)
                case .failure(let error):
                    //intentionall failed with 412
                    XCTAssert(error.kind == .preconditionFailed)
                }
                exp.fulfill()
            }
        }
    }

    func testBasicAuthen() {
        let basicAuth = HTTPBin.BasicAuth(username: "cookpad", password: "rocks!")
        wait { exp in
            basicAuth.call { result, response in
                switch result {
                case .success:
                    XCTAssert(true)
                case .failure(let error):
                    print(error)
                    XCTAssert(false)
                }
                exp.fulfill()
            }
        }

        let failBasicAuth = HTTPBin.BasicAuth(username: "cookpad", password: "rocks!", failure: true)
        wait { exp in
            failBasicAuth.call { result, response in
                switch result {
                case .success:
                    XCTAssert(false)
                case .failure(let error):
                    XCTAssert(error.kind == .unauthorized)
                }
                exp.fulfill()
            }
        }
    }
}

struct HTTPBin {
    static let url = URL(string: "https://httpbin.org")!
}

extension HTTPBin {
    struct Get : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .get
        let path: String = "/get"
        let queryParam: [String : Any] = ["foo": "bar"]
    }

    struct Post : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .post
        let path: String = "/post"
        let body: [String : Any] = ["foo": "bar"]
    }

    struct Put : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .put
        let path: String = "/put"
        let body: [String : Any] = ["foo": "bar"]
    }

    struct Delete : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .delete
        let path: String = "/delete"
        let queryParam: [String : Any] = ["foo": "bar"]
    }

    struct Status : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .get
        var path: String {
            return "/status/\(code)"
        }

        let code: Int

        init(code: Int) {
            self.code = code
        }
    }

    struct BasicAuth : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .get
        var path: String {
            return "/basic-auth/\(username)/\(password)"
        }
        var header: [String : Any] {
            let encoded = "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
            return failure ? [:] : ["Authorization": "Basic \(encoded!)"]
        }

        let username: String
        let password: String
        let failure: Bool

        init(username: String, password: String, failure: Bool = false) {
            self.username = username
            self.password = password
            self.failure = failure
        }
    }
}

extension XCTestCase {
    func wait(name description: String = #function, for handler: (XCTestExpectation) -> ()) {
        let exp = expectation(description: description)
        handler(exp)
        waitForExpectations(timeout: 15, handler: nil)
    }
}
