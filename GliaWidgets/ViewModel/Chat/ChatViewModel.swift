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
        case appendRows(Int, to: Int, animated: Bool)
        case refreshRow(Int, in: Int)
        case refreshAll
        case scrollToBottom(animated: Bool)
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

    private let sections = [
        Section<ChatItem>(0),
        Section<ChatItem>(1),
        Section<ChatItem>(2)
    ]
    private var historySection: Section<ChatItem> { return sections[0] }
    private var queueOperatorSection: Section<ChatItem> { return sections[1] }
    private var messagesSection: Section<ChatItem> { return sections[2] }

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
        appendItem(item,
                   to: queueOperatorSection,
                   animated: false)
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

    private func appendItem(_ item: ChatItem,
                            to section: Section<ChatItem>,
                            animated: Bool) {
        appendItems([item],
                    to: section,
                    animated: animated)
    }

    private func appendItems(_ items: [ChatItem],
                             to section: Section<ChatItem>,
                             animated: Bool) {
        section.append(items)
        action?(.appendRows(items.count,
                            to: section.index,
                            animated: animated))
    }

    private func setItems(_ items: [ChatItem],
                          to section: Section<ChatItem>) {
        section.set(items)
        action?(.refreshAll)
    }

    private func replace(_ outgoingMessage: OutgoingMessage,
                         with message: Message,
                         in section: Section<ChatItem>) {
        guard let index = section.items
                .enumerated()
                .first(where: {
                    switch $0.element.kind {
                    case .outgoingMessage(let message):
                        if message.id == outgoingMessage.id {
                            return true
                        } else {
                            return false
                        }
                    default:
                        return false
                    }
                })?.offset,
              let item = ChatItem(with: message)
        else { return }
        section.replaceItem(at: index, with: item)
        action?(.refreshRow(index, in: section.index))
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
            let items = messages.compactMap({ ChatItem(with: $0) })
            setItems(items, to: messagesSection)
            action?(.scrollToBottom(animated: true))
        case .error(let error):
            action?(.showAlert(alertStrings(with: error),
                               dismissed: nil))
        }
    }
}

extension ChatViewModel {
    private func send(_ message: String) {
        let outgoingMessage = OutgoingMessage(content: message)
        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)

        interactor.send(message) { message in
            self.replace(outgoingMessage,
                         with: message,
                         in: self.messagesSection)
            self.action?(.scrollToBottom(animated: true))
        } failure: { _ in
            self.action?(.showAlert(self.alertStrings.unexpectedError,
                                    dismissed: nil))
        }
    }

    private func receivedMessage(_ message: Message) {
        guard
            message.sender != .visitor,
            let item = ChatItem(with: message)
        else { return }
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))
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

    func userImageUrl(for row: Int, in section: Int) -> String? {
        guard sections[section] === queueOperatorSection else { return nil }
        let item = sections[section][row]

        // return url for last message for each operator message in newMessages

        switch item.kind {
        case .operatorMessage:
            return interactor.engagedOperator?.picture?.url
        default:
            return nil
        }
    }
}
