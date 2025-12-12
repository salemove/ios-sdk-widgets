import Foundation

final class ChatChoiceCardOption: Codable {
    let text: String?
    let value: String?
    let mesage: String?

    private let originOption: CoreSdkClient.SingleChoiceOption?

    init(with option: CoreSdkClient.SingleChoiceOption) {
        self.originOption = option
        self.text = option.text
        self.value = option.value
        self.mesage = nil
    }

    init(text: String? = nil, value: String? = nil, message: String? = nil) {
        self.text = text
        self.value = value
        self.originOption = nil
        self.mesage = message
    }

    func asSingleChoiceOption() -> CoreSdkClient.SingleChoiceOption? {
        originOption
    }
}
