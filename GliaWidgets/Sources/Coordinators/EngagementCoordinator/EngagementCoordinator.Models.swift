import UIKit

extension EngagementCoordinator {
    /// `EngagementLaunching` is used to start one of two possible flows:
    /// - `direct` case is used to start regular engagement flow with single `EngagementKind`.
    /// In this case `EngagementCoordinator` starts regular engagement.
    /// - `indirect` case is used to temporarily save initial `EngagementKind` and replace it with necessary kind.
    /// Use case is if there is pending secure conversation, but requested `EngagementKind` is
    /// one of `[.chat, . audioCall, .videoCall]`, then `EngagementCoordinator` opens
    /// ChatTranscript screen and shows Leave Engagement Dialog. Then if user presses "Leave" button,
    /// `EngagementCoordinator` replaces current screen with the one corresponding to initial `EngagementKind`.
    enum EngagementLaunching: Equatable {
        case direct(kind: EngagementKind)
        case indirect(kind: EngagementKind, initialKind: EngagementKind)

        var currentKind: EngagementKind {
            switch self {
            case let .direct(engagementKind), let .indirect(engagementKind, _):
                return engagementKind
            }
        }

        var initialKind: EngagementKind {
            switch self {
            case let .direct(engagementKind), let .indirect(_, engagementKind):
                return engagementKind
            }
        }
    }

    enum DelegateEvent: Equatable {
        case started
        case engagementChanged(EngagementKind)
        // Glia screen is closed after once an engagement is ended
        case ended
        // Glia screen is closed without having an engagement
        case closed
        case minimized
        case maximized
    }

    enum Engagement {
        case none
        case chat(ChatViewController)
        case call(CallViewController, ChatViewController, UpgradedFrom, Call)
        case secureConversations(UIViewController)
    }

    enum UpgradedFrom {
        case none
        case chat
    }
}

extension EngagementKind {
    init(with kind: CallKind) {
        switch kind {
        case .audio:
            self = .audioCall
        case .video:
            self = .videoCall
        }
    }
}
