import Foundation
import Result

public protocol Callable : Deserializable {
}

public extension Callable {
    func performTask(with request: URLRequest,
                           success: @escaping (T, HTTPURLResponse?) -> (),
                           failure: @escaping (RequestError, HTTPURLResponse?) -> (),
                           parseFailure: @escaping (RequestError, HTTPURLResponse?) -> (),
                           finish: @escaping (Void) -> () = {}) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard var response = response as? HTTPURLResponse else {
                let error = RequestError(kind: .unknown)
                failure(error, nil)
                finish()
                return
            }

            let intercept = compose(Nabe.responseInterceptors.map { $0.intercept })
            
            response = intercept(response)
            if !(200..<300 ~= response.statusCode) {
                let error = RequestError(kind: RequestError.ErrorKind(rawValue: response.statusCode)!)
                failure(error, response)
            } else if let data = data, let result = self.deserialize(data: data)  {
                success(result, response)
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
        guard let request = self.createRequest() else {
            let error = RequestError(kind: .unknown)
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
