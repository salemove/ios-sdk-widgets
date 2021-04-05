import SalemoveSDK

enum ChatAttachmentType: Int, Codable {
    case files = 0
    case singleChoice = 1
    case singleChoiceResponse = 2
    case unknown = 100

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
            self = .unknown
        }
    }
}

class ChatAttachment: Codable {
    let type: ChatAttachmentType?
    let files: [ChatEngagementFile]?
    let imageUrl: String?
    let options: [ChatChoiceCardOption]?
    let selectedOption: String?

    private enum CodingKeys: String, CodingKey {
        case type
        case files
        case imageUrl
        case options
        case selectedOption
    }

    init?(with attachment: SalemoveSDK.Attachment?) {
        guard let attachment = attachment else { return nil }
        type = ChatAttachmentType(with: attachment.type)
        files = attachment.files.map { $0.map { ChatEngagementFile(with: $0) } }
        imageUrl = attachment.imageUrl
        options = attachment.options.map { $0.map { ChatChoiceCardOption(with: $0) } }
        selectedOption = attachment.selectedOption
    }
}
