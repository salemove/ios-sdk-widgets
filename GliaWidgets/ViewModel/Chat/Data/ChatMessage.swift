import Foundation

enum ChatMessageSender: Int, Codable {
    case visitor = 0
    case `operator` = 1
    case omniguide = 2
    case system = 3
    case unknown = 100

    init(with sender: CoreSdkClient.MessageSender) {
        switch sender {
        case .visitor:
            self = .visitor
        case .operator:
            self = .operator
        case .omniguide:
            self = .omniguide
        case .system:
            self = .system
        @unknown default:
            self = .unknown
        }
    }
}

class ChatMessage: Codable {
    let id: String
    var queueID: String?
    let `operator`: ChatOperator?
    let sender: ChatMessageSender
    let content: String
    var attachment: ChatAttachment?
    var downloads = [FileDownload]()

    var isChoiceCard: Bool {
        return attachment?.type == .singleChoice
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case queueID
        case `operator`
        case sender
        case content
        case attachment
    }

    init(with message: CoreSdkClient.Message,
         queueID: String? = nil,
         operator salemoveOperator: CoreSdkClient.Operator? = nil) {
        id = message.id
        self.queueID = queueID
        self.operator = salemoveOperator.map { ChatOperator(with: $0) }
        sender = ChatMessageSender(with: message.sender)
        content = message.content
        attachment = ChatAttachment(with: message.attachment)
    }

    #if DEBUG
    init(
        id: String,
        queueID: String?,
        `operator`: ChatOperator?,
        sender: ChatMessageSender,
        content: String,
        attachment: ChatAttachment?,
        downloads: [FileDownload]
    ) {
        self.id = id
        self.queueID = queueID
        self.operator = `operator`
        self.sender = sender
        self.content = content
        self.attachment = attachment
        self.downloads = downloads
    }
    #endif
}
