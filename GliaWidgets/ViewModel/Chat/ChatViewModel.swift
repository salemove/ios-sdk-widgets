class ChatViewModel: ViewModel {
    enum Event {
        case backTapped
        case closeTapped
        case confirmedExitQueue
    }

    enum Action {
        case showAlert(AlertMessageTexts)
        case confirmExitQueue(AlertConfirmationTexts)
    }

    enum DelegateEvent {
        case back
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
        case .backTapped:
            delegate?(.back)
        case .closeTapped:
            closeTapped()
        case .confirmedExitQueue:
            endSession()
        }
    }

    private func closeTapped() {
        //TOOD check session status (in queue etc)
        action?(.confirmExitQueue(alertTexts.leaveQueue))
    }

    private func endSession() {
        delegate?(.finished)
    }
}
