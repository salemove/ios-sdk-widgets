import SalemoveSDK

enum ChatAttachmentType: Int, Codable {
    case files = 0
    case singleChoice = 1
    case singleChoiceResponse = 2

    init?(with type: SalemoveSDK.AttachmentType?) {
        switch type {
        case .files:
            self = .files
        case .singleChoice:
            self = .singleChoice
        case .singleChoiceResponse:
            self = .singleChoiceResponse
        case nil:
            return nil
        }
    }
}

class ChatAttachment: Codable {
    let type: ChatAttachmentType?
    let files: [ChatEngagementFile]?

    private enum CodingKeys: String, CodingKey {
        case type
        case files
    }

    init?(with attachment: SalemoveSDK.Attachment?) {
        guard let attachment = attachment else { return nil }
        type = ChatAttachmentType(with: attachment.type)
        files = attachment.files.map({ $0.map({ ChatEngagementFile(with: $0) }) })
    }
}
