import UIKit

public struct QueueStatusStyle {
    public var text1: String?
    public var text1Font: UIFont
    public var text1FontColor: UIColor
    public var text2: String?
    public var text2Font: UIFont
    public var text2FontColor: UIColor

    public init(text1: String?,
                text1Font: UIFont,
                text1FontColor: UIColor,
                text2: String?,
                text2Font: UIFont,
                text2FontColor: UIColor) {
        self.text1 = text1
        self.text1Font = text1Font
        self.text1FontColor = text1FontColor
        self.text2 = text2
        self.text2Font = text2Font
        self.text2FontColor = text2FontColor
    }
}
