class ChatViewModel: ViewModel {
    enum Event {
        case viewDidLoad
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

    private let interactor: Interactor
    private let alertTexts: AlertTexts

    init(interactor: Interactor, alertTexts: AlertTexts) {
        self.interactor = interactor
        self.alertTexts = alertTexts
        interactor.addObserver(self, handler: interactorEvent)
    }

    deinit {
        interactor.removeObserver(self)
    }

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
        case .backTapped:
            delegate?(.back)
        case .closeTapped:
            closeTapped()
        case .confirmedExitQueue:
            endSession()
        }
    }

    private func start() {
        interactor.enqueueForEngagement()
    }

    private func closeTapped() {
        //TOOD check session status (in queue etc)
        action?(.confirmExitQueue(alertTexts.leaveQueue))
    }

    private func endSession() {
        delegate?(.finished)
    }
}

extension ChatViewModel {
    func interactorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(let state):
            switch state {
            case .initial:
                break
            case .enqueued(_):
                break
            case .engaged:
                break
            }
        case .error(let error):
            switch error {
            case .failedToEnqueue(_):
                break
            case .failedToExitQueue(_):
                break
            case .error(_):
                break
            }
        }
    }
}
