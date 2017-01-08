import Foundation

protocol Serializable {
    associatedtype T
    func serialize(t: T) -> [String : Any]
}
