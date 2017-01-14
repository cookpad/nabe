import Foundation
import Result

public protocol Callable : Deserializable { }

public extension Callable {
    func performTask(with request: URLRequest,
                           success: @escaping (T, HTTPURLResponse?) -> (),
                           failure: @escaping (RequestError, HTTPURLResponse?) -> (),
                           parseFailure: @escaping (RequestError, HTTPURLResponse?) -> (),
                           finish: @escaping (Void) -> () = {}) -> URLSessionDataTask {

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                let error = RequestError(kind: .unknown, data: data)
                failure(error, nil)
                finish()
                return
            }

            let intercept = compose2(Nabe.responseInterceptors.map { $0.intercept })
            let interceptedResponse = intercept(response, data)

            if !(200..<300 ~= interceptedResponse.statusCode) {
                let error = RequestError(kind: RequestError.ErrorKind(rawValue: interceptedResponse.statusCode) ?? .unknown, data: data)
                failure(error, interceptedResponse)
            } else if let data = data, let result = self.deserialize(data)  {
                success(result, interceptedResponse)
            } else {
                let error = RequestError(kind: .deserialization, data: data)
                parseFailure(error, response)
            }
            finish()
      }

      task.resume()
      return task
  }
}

public protocol RequestCallable : RequestConstructable, Callable {
    func call(with handler: @escaping (Result<T, RequestError>, HTTPURLResponse?) -> ())
}

public extension RequestCallable {
    func call(with handler: @escaping (Result<T, RequestError>, HTTPURLResponse?) -> ()) {
        guard let request = createRequest() else {
            let error = RequestError(kind: .invalid, data: nil)
            handler(.failure(error), nil)
            return
        }

        _ = performTask(with: request, success: { parsed, response in
            let result: Result<T, RequestError> = .success(parsed)
            handler((result, response))
        }, failure: { (error, response) in
            let result: Result<T, RequestError> = .failure(error)
            handler((result, response))
        }, parseFailure: { (error, response) in
            let result: Result<T, RequestError> = .failure(error)
            handler((result, response))
        })
    }
}
