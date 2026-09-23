import Foundation
@testable import GliaWidgets

enum AlertKind {
    case message, singleAction, singleMediaUpgrade, confirmation
}

extension AlertKind {
    static func mock(type: AlertKind) -> AlertType {
        switch type {
        case .message:
            return .message(conf: .mock(), accessibilityIdentifier: nil, dismissed: nil, onClose: {})
        case .singleAction:
            return .singleAction(conf: .mock(), accessibilityIdentifier: "", actionTapped: {}, onClose: {})
        case .singleMediaUpgrade:
            return .singleMediaUpgrade(.mock(), accepted: {}, declined: {}, onClose: {})
        case .confirmation:
            return .confirmation(conf: .mock(), accessibilityIdentifier: "", confirmed: {}, onClose: {}, dismissed: nil)
        }
    }
}
