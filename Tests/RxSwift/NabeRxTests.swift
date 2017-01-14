import XCTest
import RxSwift
import Result
@testable import Nabe
@testable import NabeRx

class NabeRxTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGithubUser() {
        wait { exp in
            let observable = Github.User(username: "cookpad").call()
            _ = observable.subscribe(onNext: { result, response in
                switch result {
                    case let .success(value):
                        print(value)
                        XCTAssert(true)
                    case .failure:
                        XCTAssert(false) 
                }
                exp.fulfill()
            })
        }
    }
}

struct Github {
    static let url = URL(string: "https://api.github.com")!
}

extension Github {
    struct User : RxRequestCallable {
        typealias T = Dictionary<String, Any>

        let username: String
        init(username: String) {
            self.username = username
        }
        
        let baseURL: URL = url
        let method: HTTPMethod = .get
        var path: String {
            return "/users/\(username)"
        }
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
