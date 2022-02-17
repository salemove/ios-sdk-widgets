import Foundation

final class ChatChoiceCardOption: Codable {
    let text: String?
    let value: String?

    private let originOption: CoreSdkClient.SingleChoiceOption?

    init(with option: CoreSdkClient.SingleChoiceOption) {
        self.originOption = option
        self.text = option.text
        self.value = option.value
    }

    func asSingleChoiceOption() -> CoreSdkClient.SingleChoiceOption? {
        originOption
    }
}
