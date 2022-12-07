import Foundation

extension SecureConversations {
    final class WelcomeViewModel: ViewModel {
        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?

        func event(_ event: Event) {
            switch event {
            case .backTapped:
                delegate?(.backTapped)
            case .closeTapped:
                delegate?(.closeTapped)
            }
        }
    }
}

extension SecureConversations.WelcomeViewModel {
    enum Event {
        case backTapped
        case closeTapped
    }

    enum Action {
        case start
    }

    enum DelegateEvent {
        case backTapped
        case closeTapped
    }

    enum StartAction {
        case none
    }
}
