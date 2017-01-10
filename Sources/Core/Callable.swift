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
                let error = RequestError(kind: .unknown)
                failure(error, nil)
                finish()
                return
            }

            let intercept = compose(Nabe.responseInterceptors.map { $0.intercept })
            let (interceptedData, interceptedResponse) = intercept((data, response))

            if !(200..<300 ~= interceptedResponse.statusCode) {
                let error = RequestError(kind: RequestError.ErrorKind(rawValue: interceptedResponse.statusCode)!)
                failure(error, interceptedResponse)
            } else if let data = interceptedData, let result = self.deserialize(data: data)  {
                success(result, interceptedResponse)
            } else {
                let error = RequestError(kind: .deserialization)
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
            let error = RequestError(kind: .cannotCreateRequest)
            handler(.failure(error), nil)
            return
        }

        let task = performTask(with: request, success: { parsed, response in
            let result: Result<T, RequestError> = .success(parsed)
            handler((result, response))
        }, failure: { (error, response) in
            let result: Result<T, RequestError> = .failure(error)
            handler((result, response))
        }, parseFailure: { (error, response) in
            let result: Result<T, RequestError> = .failure(error)
            handler((result, response))
        })

        task.resume()
    }
}
