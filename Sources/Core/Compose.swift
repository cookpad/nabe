import Foundation

internal func compose<T>(_ ts: [(T) -> T]) -> (T) -> T {
    return { t in 
        ts.reversed().reduce(t) { (composed, f) -> T in
            f(composed)
        }
    }
}
