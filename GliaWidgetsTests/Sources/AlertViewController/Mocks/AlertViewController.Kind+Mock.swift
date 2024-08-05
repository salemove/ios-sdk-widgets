import Foundation
@testable import GliaWidgets

enum AlertKind {
    case message, singleAction, singleMediaUpgrade, screenShareOffer, confirmation
}

extension AlertKind {
    static func mock(type: AlertKind) -> AlertType {
        switch type {
        case .message:
            return .message(conf: .mock(), accessibilityIdentifier: nil, dismissed: nil)
        case .singleAction:
            return .singleAction(conf: .mock(), accessibilityIdentifier: "", actionTapped: {})
        case .singleMediaUpgrade:
            return .singleMediaUpgrade(.mock(), accepted: {}, declined: {})
        case .screenShareOffer:
            return .screenShareOffer(.mock(), accepted: {}, declined: {})
        case .confirmation:
            return .confirmation(conf: .mock(), accessibilityIdentifier: "", confirmed: {})
        }
    }
}
