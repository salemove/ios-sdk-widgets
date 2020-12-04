class ChatViewModel: ViewModel {
    enum Event {
        case alertTapped
        case confirmTapped
        case backTapped
        case closeTapped
    }

    enum Action {
        case showAlert(AlertMessageTexts)
        case confirmExitQueue(AlertConfirmationTexts)
    }

    enum DelegateEvent {
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let alertTexts: AlertTexts

    init(alertTexts: AlertTexts) {
        self.alertTexts = alertTexts
    }

    public func event(_ event: Event) {
        switch event {
        case .alertTapped:
            action?(.showAlert(alertTexts.unexpectedError))
        case .confirmTapped:
            action?(.confirmExitQueue(alertTexts.leaveQueue))
        case .backTapped:
            delegate?(.finished)
        case .closeTapped:
            delegate?(.finished)
        }
    }
}
