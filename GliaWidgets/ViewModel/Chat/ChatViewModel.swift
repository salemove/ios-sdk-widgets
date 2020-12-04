class ChatViewModel: ViewModel {
    enum Event {
        case alertTapped
        case confirmTapped
        case backTapped
        case closeTapped
    }

    enum Action {
        case showAlert(AlertMessageContent)
    }

    enum DelegateEvent {
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let alertContents: AlertContents

    init(alertContents: AlertContents) {
        self.alertContents = alertContents
    }

    public func event(_ event: Event) {
        switch event {
        case .alertTapped:
            action?(.showAlert(alertContents.unexpectedError))
        case .confirmTapped:
            break
        case .backTapped:
            delegate?(.finished)
        case .closeTapped:
            delegate?(.finished)
        }
    }
}
