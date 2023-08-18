import UIKit

public enum ColorType: Equatable {
    case fill(color: UIColor)
    case gradient(colors: [CGColor])

    public static func == (lhs: ColorType, rhs: ColorType) -> Bool {
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

    var color: UIColor {
        switch self {
        case let .fill(color):
            return color
        case let .gradient(colors):
            return UIColor(cgColor: colors.first ?? .clear)
        }
    }
}
