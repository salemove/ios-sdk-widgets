import SalemoveSDK

class ChatViewModel: EngagementViewModel, ViewModel {
    enum Event {
        case viewDidLoad
        case backTapped
        case closeTapped
        case sendTapped(message: String)
    }

    enum Action {
        case queueWaiting
        case queueConnecting
        case queueConnected(name: String?, imageUrl: String?)
        case showEndButton
        case setMessageEntryEnabled(Bool)
        case appendRows(Int)
        case refreshItems
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

    private var items = [ChatItem]()

    override init(interactor: Interactor, alertStrings: AlertStrings) {
        super.init(interactor: interactor, alertStrings: alertStrings)
    }

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
        case .backTapped:
            delegate?(.back)
        case .closeTapped:
            closeTapped()
        case .sendTapped(message: let message):
            send(message)
        }
    }

    private func start() {
        let item = ChatItem(kind: .queueOperator)
        appendItem(item)
        action?(.setMessageEntryEnabled(false))
        enqueue()
    }

    private func enqueue() {
        interactor.enqueueForEngagement {

        } failure: { error in
            switch error.error {
            case let queueError as QueueError:
                switch queueError {
                case .queueClosed, .queueFull:
                    self.action?(.showAlert(self.alertStrings.operatorsUnavailable,
                                            dismissed: { self.end() }))
                default:
                    self.action?(.showAlert(self.alertStrings(with: error),
                                            dismissed: { self.end() }))
                }
            default:
                self.action?(.showAlert(self.alertStrings(with: error),
                                        dismissed: { self.end() }))
            }
        }
    }

    private func end() {
        interactor.endSession {
            self.delegate?(.finished)
        } failure: { _ in
            self.delegate?(.finished)
        }
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            action?(.confirm(alertStrings.leaveQueue,
                             confirmed: { self.end() }))
        case .engaged:
            action?(.confirm(alertStrings.endEngagement,
                             confirmed: { self.end() }))
        default:
            end()
        }
    }

    private func appendItem(_ item: ChatItem) {
        appendItems([item])
    }

    private func appendItems(_ newItems: [ChatItem]) {
        items.append(contentsOf: newItems)
        action?(.appendRows(newItems.count))
    }

    override func interactorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(let state):
            switch state {
            case .inactive:
                delegate?(.finished)
            case .enqueueing:
                action?(.queueWaiting)
            case .enqueued:
                action?(.queueConnecting)
            case .engaged(let engagedOperator):
                action?(.queueConnected(name: engagedOperator?.name,
                                        imageUrl: engagedOperator?.picture?.url))
                action?(.showEndButton)
                action?(.setMessageEntryEnabled(true))
            }
        case .receivedMessage(let message):
            receivedMessage(message)
        case .error(let error):
            action?(.showAlert(alertStrings(with: error),
                               dismissed: nil))
        }
    }
}

extension ChatViewModel {
    private func send(_ message: String) {

    }

    private func receivedMessage(_ message: Message) {
        let item = ChatItem(kind: .receivedMessage(message,
                                                   interactor.engagedOperator))
        appendItem(item)
    }
}

extension ChatViewModel {
    var numberOfItems: Int { return items.count }

    func item(for row: Int) -> ChatItem {
        return items[row]
    }

    func senderImageUrl(for row: Int) -> String? {
        let item = items[row]

        if case let .receivedMessage(_, engagedOperator) = item.kind {
            return engagedOperator?.picture?.url
        }

        return nil
    }
}
