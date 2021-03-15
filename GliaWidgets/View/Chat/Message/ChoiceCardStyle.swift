import UIKit

public final class ChoiceCardStyle: ChatMessageStyle {
    public var frameColor: UIColor
    public var choiceOption: ChatTextContentStyle

    public init(
        mainText: ChatTextContentStyle,
        frameColor: UIColor,
        imageFile: ChatImageFileContentStyle,
        choiceOption: ChatTextContentStyle
    ) {
        self.frameColor = frameColor
        self.choiceOption = choiceOption
        super.init(text: mainText, imageFile: imageFile)
    }
}
