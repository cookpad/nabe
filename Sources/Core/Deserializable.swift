import Foundation

public protocol Deserializable {
    associatedtype T
    func deserialize(data: Data) -> T?
}

public extension Deserializable {
    func deserialize(data: Data) -> T? {
        return try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? T
    }
}
