import Foundation
import UIKit

extension Array where Element == UIColor {
    func convertToCgColors() -> [CGColor] {
        var colors = [CGColor]()

        self.forEach {
            colors.append($0.cgColor)
        }
        return colors
    }
}

extension Array where Element == String {

    func convertToCgColors() -> [CGColor] {
        var colors = [CGColor]()
        self.forEach {
            colors.append(UIColor(hex: $0).cgColor)
        }
        return colors
    }
}
