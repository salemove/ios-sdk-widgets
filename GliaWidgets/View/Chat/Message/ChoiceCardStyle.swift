import UIKit

/// Style of the choice card sent to the visitor by the AI engine.
public final class ChoiceCardStyle: OperatorChatMessageStyle {
    /// Color of the choice card's border.
    public var frameColor: UIColor

    /// Styles of the choice card's answer options.
    public var choiceOption: ChoiceCardOptionStyle

    ///
    /// - Parameters:
    ///   - mainText: Style of the choice card's main text.
    ///   - frameColor: Color of the choice card's border.
    ///   - imageFile: Style of a choice card's image.
    ///   - fileDownload: Style of a choice card's attached files.
    ///   - operatorImage: Style of the operator's image to the left of a choice card.
    ///   - choiceOption: Styles of the choice card's answer options.
    public init(
        mainText: ChatTextContentStyle,
        frameColor: UIColor,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        operatorImage: UserImageStyle,
        choiceOption: ChoiceCardOptionStyle
    ) {
        self.frameColor = frameColor
        self.choiceOption = choiceOption
        super.init(
            text: mainText,
            imageFile: imageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage
        )
    }
}
