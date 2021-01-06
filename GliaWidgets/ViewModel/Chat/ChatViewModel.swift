import SalemoveSDK

class ChatViewModel: EngagementViewModel, ViewModel {
    typealias Strings = L10n.Chat

    enum Event {
        case viewDidLoad
        case backTapped
        case closeTapped
        case messageTextChanged(String)
        case sendTapped(message: String)
    }

    enum Action {
        case queueWaiting
        case queueConnecting
        case queueConnected(name: String?, imageUrl: String?)
        case showEndButton
        case setMessageEntryEnabled(Bool)
        case appendRows(Int, to: Int, animated: Bool)
        case refreshRow(Int, in: Int, animated: Bool)
        case refreshAll
        case scrollToBottom(animated: Bool)
        case updateItemsUserImage(animated: Bool)
        case confirm(AlertConfirmationStrings,
                     confirmed: (() -> Void)?)
        case showAlert(AlertMessageStrings,
                       dismissed: (() -> Void)?)
    }

    enum DelegateEvent {
        case back
        case operatorImage(url: String?)
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
    private let storage = ChatStorage()

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
        case .messageTextChanged(let message):
            sendMessagePreview(message)
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
        storage.setQueue(withID: interactor.queueID)
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
                    self.action?(.showAlert(self.alertStrings.unexpectedError,
                                            dismissed: { self.end() }))
                }
            default:
                self.action?(.showAlert(self.alertStrings.unexpectedError,
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
                    guard case let .outgoingMessage(message) = $0.element.kind else { return false }
                    return message.id == outgoingMessage.id
                })?.offset
        else { return }

        let status = Strings.Message.Status.delivered
        let item = ChatItem(kind: .visitorMessage(message, status: status))
        section.replaceItem(at: index, with: item)
        action?(.refreshRow(index, in: section.index, animated: false))
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
                break
            case .engaged(let engagedOperator):
                let name = engagedOperator?.name
                let pictureUrl = engagedOperator?.picture?.url
                storage.setOperator(name: name ?? "", pictureUrl: pictureUrl)
                action?(.queueConnected(name: name, imageUrl: pictureUrl))
                action?(.showEndButton)
                action?(.setMessageEntryEnabled(true))
                delegate?(.operatorImage(url: engagedOperator?.picture?.url))
            }
        case .receivedMessage(let message):
            receivedMessage(message)
        case .messagesUpdated(let messages):
            let items = messages.compactMap({ ChatItem(with: $0) })
            setItems(items, to: messagesSection)
            action?(.scrollToBottom(animated: true))
        case .error:
            action?(.showAlert(alertStrings.unexpectedError,
                               dismissed: nil))
        }
    }
}

extension ChatViewModel {
    private func sendMessagePreview(_ message: String) {
        interactor.sendMessagePreview(message)
    }

    private func send(_ message: String) {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let outgoingMessage = OutgoingMessage(content: message)
        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        interactor.send(message) { message in
            self.sendMessagePreview("")
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
        switch message.sender {
        case .visitor:
            storage.storeMessage(message)
        case .operator:
            guard let item = ChatItem(with: message) else { break }
            storage.storeMessage(message)
            appendItem(item, to: messagesSection, animated: true)
            action?(.scrollToBottom(animated: true))
            action?(.updateItemsUserImage(animated: true))
        default:
            break
        }
    }
}

extension ChatViewModel {
    var numberOfSections: Int { return sections.count }

    func numberOfItems(in section: Int) -> Int {
        return sections[section].itemCount
    }

    func item(for row: Int, in section: Int) -> ChatItem {
        let section = sections[section]
        let item = section[row]

        if section === messagesSection {
            switch item.kind {
            case .operatorMessage(let message, showsImage: _, imageUrl: _):
                let nextItem = section.item(after: row)
                if nextItem == nil || nextItem?.isOperatorMessage == false {
                    let imageUrl = interactor.engagedOperator?.picture?.url
                    let kind: ChatItem.Kind = .operatorMessage(message,
                                                               showsImage: true,
                                                               imageUrl: imageUrl)
                    return ChatItem(kind: kind)
                }
            default:
                break
            }
        }

        return item
    }
}
