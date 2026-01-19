import Foundation

enum EngagementState: Equatable {
    case initial
    case queue
    case connecting(name: String?, imageUrl: String?)
    case connected(name: String?, imageUrl: String?)
    case transferring
    case onHold(name: String?, imageUrl: String?, onHoldText: String, descriptionText: String?)

    var isOnHold: Bool {
        if case .onHold = self { return true }
        return false
    }

    func applyingOnHold(
        _ onHold: Bool,
        onHoldText: String,
        descriptionText: String?,
        operatorNameOverride: String?
    ) -> Self {
        switch (self, onHold) {
        // Turn ON hold
        case (.connected(let name, let url), true):
            return .onHold(
                name: name ?? operatorNameOverride,
                imageUrl: url,
                onHoldText: onHoldText,
                descriptionText: descriptionText
            )

        // Turn OFF hold -> unwrap
        case (.onHold(let name, let url, _, _), false):
            return .connected(name: name ?? operatorNameOverride, imageUrl: url)
        default:
            return self
        }
    }
}
