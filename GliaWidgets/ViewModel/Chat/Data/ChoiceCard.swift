final class ChoiceCard: Codable {
    let text: String
    let imageUrl: String?
    let options: [ChatChoiceCardOption]?
    let selectedOption: String?
    let isActive: Bool

    private enum CodingKeys: String, CodingKey {
        case text
        case imageUrl
        case options
        case selectedOption
        case isActive
    }

    init(with message: ChatMessage, isActive: Bool) {
        text = message.content
        imageUrl = message.attachment?.imageUrl
        options = message.attachment?.options
        self.selectedOption = message.attachment?.selectedOption
        self.isActive = isActive
    }
}
