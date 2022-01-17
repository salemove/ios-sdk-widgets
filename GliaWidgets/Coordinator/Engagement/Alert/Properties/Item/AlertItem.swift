import UIKit

enum AlertItem {
    case title(String)
    case message(String)
    case illustration(UIImage)
    case actions([AlertAction])
    case poweredByGlia
}

extension AlertItem {
    var isActionsItem: Bool {
        switch self {
        case .actions:
            return true

        default:
            return false
        }
    }
}
