import Foundation

final class ChatChoiceCardOption: Codable {
    let text: String?
    let value: String?

    private enum CodingKeys: String, CodingKey {
        case text
        case value
    }

    init(with option: CoreSdkClient.SingleChoiceOption) {
        text = option.text
        value = option.value
    }
}
