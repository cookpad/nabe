import Foundation

internal func compose<T>(_ ts: [(T) -> T]) -> (T) -> T {
    return { t in 
        ts.reversed().reduce(t) { (composed, f) -> T in
            f(composed)
        }
    }
}

internal func compose2<T, U>(_ ts: [(T, U) -> T]) -> (T, U) -> T {
    return { t, u in
        ts.reversed().reduce(t) { (composed, f) -> T in
            f(composed, u)
        }
    }
}
