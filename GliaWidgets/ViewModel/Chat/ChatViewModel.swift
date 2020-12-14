import SalemoveSDK

class ChatViewModel: ViewModel {
    enum Event {
        case viewDidLoad
        case backTapped
        case closeTapped
    }

    enum Action {
        case queueWaiting
        case queueConnecting(name: String)
        case queueConnected(name: String)
        case appendRows(Int)
        case refreshChatItems
        case confirm(AlertConfirmationStrings,
                     confirmed: (() -> Void)?)
        case showAlert(AlertMessageStrings,
                       dismissed: (() -> Void)?)
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
            enqueue()
        case .backTapped:
            delegate?(.back)
        case .closeTapped:
            closeTapped()
        }
    }

    private func enqueue() {
        interactor.enqueueForEngagement {

        } failure: { error in
            switch error.error {
            case is QueueError:
                break
            default:
                let strings = AlertMessageStrings(with: error,
                                                  templateStrings: self.alertStrings.apiError)
                let dismissed = { self.end() }
                self.action?(.showAlert(strings, dismissed: dismissed))
            }
        }
    }

    private func end() {
        interactor.endSession {

        } failure: { error in

        }
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            let confirmed = { self.end() }
            action?(.confirm(alertStrings.leaveQueue, confirmed: confirmed))
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
            case .inactive:
                break
            case .enqueueing:
                action?(.queueWaiting)
            case .enqueued(_):
                action?(.queueConnecting(name: "Blah"))
            case .engaged:
                action?(.queueConnected(name: "Blah"))
            }
        case .error(let error):
            break
        }
    }
}
