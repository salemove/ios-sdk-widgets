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
        case appendRows(Int, to: Int)
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

    private class Section {
        let index: Int

        private var items = [ChatItem]()

        var itemCount: Int { return items.count }

        init(_ index: Int) {
            self.index = index
        }

        subscript(index: Int) -> ChatItem {
            get { return items[index] }
            set(newValue) { items[index] = newValue }
        }

        func set(_ newItems: [ChatItem]) {
            items.append(contentsOf: newItems)
        }

        func append(_ item: ChatItem) {
            items.append(item)
        }

        func append(_ newItems: [ChatItem]) {
            items.append(contentsOf: newItems)
        }
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let sections = [Section(0), Section(1), Section(2)]
    private var oldMessagesSection: Section { return sections[0] }
    private var queueOperatorSection: Section { return sections[1] }
    private var newMessagesSection: Section { return sections[2] }

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
        appendItem(item, to: queueOperatorSection)
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

    private func appendItem(_ item: ChatItem, to section: Section) {
        appendItems([item], to: section)
    }

    private func appendItems(_ items: [ChatItem], to section: Section) {
        section.append(items)
        action?(.appendRows(items.count, to: section.index))
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
        case .messagesUpdated(let messages):
            /*let engagedOperator = interactor.engagedOperator
            let items: [ChatItem] = messages.map {
                ChatItem(kind: .receivedMessage($0, engagedOperator))
            }
            appendItems(items)*/
        break
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
        guard let item = ChatItem(with: message) else { return }
        appendItem(item, to: newMessagesSection)
    }
}

extension ChatViewModel {
    var numberOfSections: Int { return sections.count }

    func numberOfItems(in section: Int) -> Int {
        return sections[section].itemCount
    }

    func item(for row: Int, in section: Int) -> ChatItem {
        return sections[section][row]
    }

    func senderImageUrl(for row: Int, in section: Int) -> String? {
        guard sections[section] === queueOperatorSection else { return nil }
        let item = sections[section][row]

        switch item.kind {
        case .operatorMessage:
            return interactor.engagedOperator?.picture?.url
        default:
            return nil
        }
    }
}
