class ChatViewModel: ViewModel {
    enum Event {
        case viewDidLoad
        case backTapped
        case closeTapped
        case confirmedExitQueue
    }

    enum Action {
        case queueWaiting
        case queueConnecting(name: String)
        case queueConnected(name: String)
        case appendRows(Int)
        case refreshChatItems
        case showAlert(AlertMessageStrings)
        case confirmExitQueue(AlertConfirmationStrings)
    }

    enum DelegateEvent {
        case back
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let alertStrings: AlertStrings
    private var chatItems = [ChatItem]()

    init(interactor: Interactor, alertStrings: AlertStrings) {
        self.interactor = interactor
        self.alertStrings = alertStrings

        interactor.addObserver(self, handler: interactorEvent)
    }

    deinit {
        interactor.removeObserver(self)
    }

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            startSession()
        case .backTapped:
            delegate?(.back)
        case .closeTapped:
            closeTapped()
        case .confirmedExitQueue:
            endSession()
        }
    }

    private func startSession() {
        interactor.enqueueForEngagement()
    }

    private func endSession() {
        interactor.endSession()
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            action?(.confirmExitQueue(alertStrings.leaveQueue))
        default:
            break
        }
    }

    private func appendItem(_ item: ChatItem) {
        appendItems([item])
    }

    private func appendItems(_ items: [ChatItem]) {
        chatItems.append(contentsOf: items)
        action?(.appendRows(items.count))
    }
}

extension ChatViewModel {
    var numberOfItems: Int { return chatItems.count }

    func item(for row: Int) -> ChatItem {
        return chatItems[row]
    }
}

extension ChatViewModel {
    func interactorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(let state):
            switch state {
            case .initial:
                break
            case .enqueueing:
                action?(.queueWaiting)
            case .enqueued(_):
                action?(.queueConnecting(name: "Blah"))
            case .engaged:
                action?(.queueConnected(name: "Blah"))
            case .sessionEnded:
                delegate?(.finished)
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
