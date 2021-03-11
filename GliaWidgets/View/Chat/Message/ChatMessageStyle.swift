import UIKit

public class ChatMessageStyle {
    public var text: ChatTextContentStyle
    public var imageFile: ChatMessageImageFileContentStyle

    public init(text: ChatTextContentStyle,
                imageFile: ChatMessageImageFileContentStyle) {
        self.text = text
        self.imageFile = imageFile
    }
}
