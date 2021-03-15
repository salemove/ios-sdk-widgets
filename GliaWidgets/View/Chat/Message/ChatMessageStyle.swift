import UIKit

public class ChatMessageStyle {
    public var text: ChatTextContentStyle
    public var imageFile: ChatImageFileContentStyle

    public init(text: ChatTextContentStyle,
                imageFile: ChatImageFileContentStyle) {
        self.text = text
        self.imageFile = imageFile
    }
}
