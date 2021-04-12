import UIKit

public final class ChoiceCardStyle: OperatorChatMessageStyle {
    public var frameColor: UIColor
    public var choiceOption: ChoiceCardOptionStyle

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
