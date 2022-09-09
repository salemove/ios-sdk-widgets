import UIKit

public enum ColorType {
    case fill(color: UIColor)
    case gradient(colors: [CGColor])

    static func == (lhs: ColorType, rhs: ColorType) -> Bool {
        switch (lhs, rhs) {
        case (.fill, .gradient):
            return false
        case (.fill(let lhsType), .fill(let rhsType)):
            return lhsType == rhsType
        case (.gradient(let lhsType), .gradient(let rhsType)):
            return lhsType == rhsType
        case (.gradient, .fill):
            return false
        }
    }
}
