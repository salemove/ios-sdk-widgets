import Foundation
@testable import GliaWidgets

enum AlertKind {
    case message, singleAction, singleMediaUpgrade, screenShareOffer, confirmation
}

extension AlertViewController.Kind {
    static func mock(kind: AlertKind) -> Self {
        switch kind {
        case .message:
            return .message(.mock(), accessibilityIdentifier: nil, dismissed: nil)
        case .singleAction:
            return .singleAction(.mock(), accessibilityIdentifier: "", actionTapped: {})
        case .singleMediaUpgrade:
            return .singleMediaUpgrade(.mock(), accepted: {}, declined: {})
        case .screenShareOffer:
            return .screenShareOffer(.mock(), accepted: {}, declined: {})
        case .confirmation:
            return .confirmation(.mock(), accessibilityIdentifier: "", confirmed: {})
        }
    }
}
