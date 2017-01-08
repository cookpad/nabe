import XCTest
@testable import Nabe

class NabeTests: XCTestCase {

    override static func setUp() {
        Nabe.requestInterceptors.append(CURLRequestInterceptor(tag: "CURL log"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHTTPBinGet() {
        wait { exp in
            HTTPBin.Get().call { result, response in
                switch result {
                    case let .success(value):
                        print(value)
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
                case let .success(value):
                    print(value)
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
                case let .success(value):
                    print(value)
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
                case let .success(value):
                    print(value)
                    XCTAssert(true)
                case .failure:
                    XCTAssert(false)
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
        let queryParam: [String : Any] = ["foo": "bar"]
    }

    struct Put : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .put
        let path: String = "/put"
        let queryParam: [String : Any] = ["foo": "bar"]
    }

    struct Delete : RequestCallable {
        typealias T = Dictionary<String, Any>

        let baseURL: URL = url
        let method: HTTPMethod = .delete
        let path: String = "/delete"
        let queryParam: [String : Any] = ["foo": "bar"]
    }
}

extension XCTestCase {
    func wait(name description: String = #function, for handler: (XCTestExpectation) -> ()) {
        let exp = expectation(description: description)
        handler(exp)
        waitForExpectations(timeout: 15, handler: nil)
    }
}
