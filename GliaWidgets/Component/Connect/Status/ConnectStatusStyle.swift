import UIKit

public struct ConnectStatusStyle {
    public var firstText: String?
    public var firstTextFont: UIFont
    public var firstTextFontColor: UIColor
    public var secondText: String?
    public var secondTextFont: UIFont
    public var secondTextFontColor: UIColor

    public init(firstText: String?,
                firstTextFont: UIFont,
                firstTextFontColor: UIColor,
                secondText: String?,
                secondTextFont: UIFont,
                secondTextFontColor: UIColor) {
        self.firstText = firstText
        self.firstTextFont = firstTextFont
        self.firstTextFontColor = firstTextFontColor
        self.secondText = secondText
        self.secondTextFont = secondTextFont
        self.secondTextFontColor = secondTextFontColor
    }
}
