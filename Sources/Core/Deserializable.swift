import Foundation

public protocol Deserializable {
    associatedtype T
    func deserialize(_ data: Data) -> T?
}

public extension Deserializable {
    func deserialize(_ data: Data) -> T? {
        guard let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? T else {
            return nil
        }
        return result
    }
}
