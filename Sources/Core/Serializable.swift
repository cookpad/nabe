import Foundation

protocol Serializable {
    associatedtype T
    func serialize(_ t: T) -> [String : Any]
}
