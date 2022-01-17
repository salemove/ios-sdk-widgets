import SalemoveSDK

enum MessageState {
    case received
    case read
}

protocol UnreadMessagesCounter {
    var unreadMessagesCount: Observable<Int> { get }
}

final class MessageDispatcher: UnreadMessagesCounter {
    var unreadMessagesCount: Observable<Int> {
        unreadMessagesCountSubject
    }

    var messageReceived: Observable<SalemoveSDK.Message> {
        messageReceivedSubject
    }

    private let interactor: Interactor
    private let chatStorage: ChatStorage
    private let unreadMessagesCountSubject = CurrentValueSubject<Int>(0)
    private let messageReceivedSubject = PublishSubject<SalemoveSDK.Message>()

    private var messages: [Message: MessageState] = [:]
    private var disposables: [Disposable] = []

    init(
        interactor: Interactor,
        chatStorage: ChatStorage
    ) {
        self.interactor = interactor
        self.chatStorage = chatStorage

        setup()
    }

    func markMessageAsRead(messageId: String) {
        guard
            let message = messages.keys.first(where: { $0.id == messageId })
        else { return }

        messages[message] = .read

        unreadMessagesCountSubject.send(numberOfUnreadMessages())
    }

    private func onMessageReceived(message: SalemoveSDK.Message) {
        guard chatStorage.isNewMessage(message) else { return }

        chatStorage.storeMessage(
            message,
            queueID: interactor.queueID,
            operator: interactor.engagedOperator
        )

        messages[message] = .received

        messageReceivedSubject.send(message)
        unreadMessagesCountSubject.send(numberOfUnreadMessages())
    }

    private func setup() {
        interactor.event
            .observe({ [weak self] in
                switch $0 {
                case .receivedMessage(let message):
                    self?.onMessageReceived(message: message)

                default:
                    break
                }
            })
            .add(to: &disposables)
    }

    private func numberOfUnreadMessages() -> Int {
        return [MessageState](messages.values)
            .filter({ $0 == .received })
            .count
    }
}
