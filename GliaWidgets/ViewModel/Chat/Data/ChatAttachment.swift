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
        @unknown default:
            return nil
        }
    }
}

class ChatAttachment: Codable {
    let type: ChatAttachmentType?
    let files: [ChatEngagementFile]?
    let options: [ChatChoiceCardOption]?

    private enum CodingKeys: String, CodingKey {
        case type
        case files
        case options
    }

    init?(with attachment: SalemoveSDK.Attachment?) {
        guard let attachment = attachment else { return nil }
        type = ChatAttachmentType(with: attachment.type)
        files = attachment.files.map { $0.map { ChatEngagementFile(with: $0) } }
        options = attachment.options.map { $0.map { ChatChoiceCardOption(with: $0) } }
    }
}
