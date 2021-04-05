final class ChoiceCard: Codable {
    let text: String
    let imageUrl: String?
    let options: [ChatChoiceCardOption]?
    let selectedOption: String?

    private enum CodingKeys: String, CodingKey {
        case text
        case imageUrl
        case options
        case selectedOption
    }

    init(with message: ChatMessage) {
        text = message.content
        imageUrl = message.attachment?.imageUrl
        options = message.attachment?.options
        selectedOption = message.attachment?.selectedOption
    }
}
