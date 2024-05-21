import Foundation
import GliaCoreSDK

enum ChatMessageSender: Int, Codable {
    case visitor = 0
    case `operator` = 1
    case omniguide = 2
    case system = 3
    case unknown = 100

    init(with sender: CoreSdkClient.MessageSender) {
        switch sender.type {
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
    typealias MessageId = String

    let id: MessageId
    let `operator`: ChatOperator?
    let sender: ChatMessageSender
    let content: String
    var attachment: ChatAttachment?
    var downloads = [FileDownload]()
    var metadata: MessageMetadata?

    var cardType: ChatMessageCardType {
        if let response = try? metadata?.decode(GvaResponseText.self), response.type == .plainText {
            return .gvaResponseText(response)
        }

        if let response = try? metadata?.decode(GvaButton.self) {
            if response.type == .persistentButtons {
                return .gvaPersistenButton(response)
            } else if response.type == .quickReplies {
                return .gvaQuickReply(response)
            }
        }

        if let response = try? metadata?.decode(GvaGallery.self), response.type == .galleryCards {
            return .gvaGallery(response)
        }

        if attachment?.type == .singleChoice {
            return metadata != nil ? .customCard : .choiceCard
        }

        return .none
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case `operator`
        case sender
        case content
        case attachment
        case metadata
    }

    init(with message: CoreSdkClient.Message,
         queueID: String? = nil,
         operator salemoveOperator: CoreSdkClient.Operator? = nil) {
        id = message.id

        if let salemoveOperator = salemoveOperator {
            self.operator = ChatOperator(with: salemoveOperator)
        } else if let name = message.sender.name {
            self.operator = ChatOperator(name: name, pictureUrl: message.sender.picture?.url)
        } else {
            self.operator = nil
        }

        sender = ChatMessageSender(with: message.sender)
        content = message.content
        attachment = ChatAttachment(with: message.attachment)
        metadata = message.metadata
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.operator = try container.decodeIfPresent(ChatOperator.self, forKey: .operator)
        self.sender = try container.decode(ChatMessageSender.self, forKey: .sender)
        self.content = try container.decode(String.self, forKey: .content)
        self.attachment = try container.decodeIfPresent(ChatAttachment.self, forKey: .attachment)
        if (try? container.decodeNil(forKey: .metadata)) == false {
            let metadataContainer = try decoder.container(keyedBy: MessageMetadata.CodingKeys.self)
            self.metadata = .init(container: metadataContainer)
        } else {
            self.metadata = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(`operator`, forKey: .operator)
        try container.encode(sender, forKey: .sender)
        try container.encode(content, forKey: .content)
        try container.encode(attachment, forKey: .attachment)
        let metadata = try? metadata?.decode([String: AnyCodable].self)
        try container.encode(metadata, forKey: .metadata)
    }

    init(
        id: String,
        `operator`: ChatOperator?,
        sender: ChatMessageSender,
        content: String,
        attachment: ChatAttachment?,
        downloads: [FileDownload],
        metadata: MessageMetadata? = nil
    ) {
        self.id = id
        self.operator = `operator`
        self.sender = sender
        self.content = content
        self.attachment = attachment
        self.downloads = downloads
        self.metadata = metadata
    }
}
