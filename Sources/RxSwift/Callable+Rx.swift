import Foundation
import Nabe
import RxSwift
import Result

public protocol RxRequestCallable : RequestConstructable, Callable {
    func call() -> Observable<(Result<T, RequestError>, HTTPURLResponse?)>
}

public extension RxRequestCallable {
    func call() -> Observable<(Result<T, RequestError>, HTTPURLResponse?)> {
        return Observable.create { observer in
            guard let request = self.createRequest() else { return Disposables.create() }
    
            let task = self.performTask(with: request, success: { parsed, response in
                observer.onNext((.success(parsed), response))
                }, failure: { error, response in
                    observer.onNext((.failure(error), response))
                }, parseFailure: { error, response in
                    observer.onNext((.failure(error), response))
                }, finish: {
                    observer.onCompleted()
                })
    
            return Disposables.create(with: task.cancel)
        }
    }
}
