import UIKit

public final class ChoiceCardStyle: ChatMessageStyle {
    public var frameColor: UIColor
    public var choiceOption: ChatChoiceOptionContentStyle

    public init(
        mainText: ChatTextContentStyle,
        frameColor: UIColor,
        imageFile: ChatImageFileContentStyle,
        choiceOption: ChatChoiceOptionContentStyle
    ) {
        self.frameColor = frameColor
        self.choiceOption = choiceOption
        super.init(text: mainText, imageFile: imageFile)
    }
}
