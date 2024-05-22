import Foundation
import UIKit

extension Array where Element == UIColor {
    func convertToCgColors() -> [CGColor] {
        return map(\.cgColor)
    }
}

extension Array where Element == String {
    func convertToCgColors() -> [CGColor] {
        return map { UIColor(hex: $0).cgColor }
    }
}
