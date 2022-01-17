import SalemoveSDK

enum MessageState {
    case received
    case read
}

protocol UnreadMessagesCounter {
    var unreadMessagesCount: ObservableValue<Int> { get }
}

final class MessageDispatcher: UnreadMessagesCounter {
    var unreadMessagesCount = ObservableValue<Int>(with: 0)
    var messageReceived = ObservableValue<SalemoveSDK.Message?>(with: nil)

    private let interactor: Interactor
    private let chatStorage: ChatStorage
    private var messages: [Message: MessageState] = [:]

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

        unreadMessagesCount.value = numberOfUnreadMessages()
    }

    private func onMessageReceived(message: SalemoveSDK.Message) {
        guard chatStorage.isNewMessage(message) else { return }

        chatStorage.storeMessage(
            message,
            queueID: interactor.queueID,
            operator: interactor.engagedOperator
        )

        messages[message] = .received
 
        messageReceived.value = message
        unreadMessagesCount.value = numberOfUnreadMessages()
    }

    private func setup() {
        interactor.addObserver(self, handler: { [weak self] in
            switch $0 {
            case .receivedMessage(let message):
                self?.onMessageReceived(message: message)

            default:
                break
            }
        })
    }

    private func numberOfUnreadMessages() -> Int {
        return [MessageState](messages.values)
            .filter({ $0 == .received })
            .count
    }
}
