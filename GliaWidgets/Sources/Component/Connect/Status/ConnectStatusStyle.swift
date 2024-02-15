import UIKit

/// Style of a connect status. These are used when visitor is in enqueued, connecting, and connected state.
public struct ConnectStatusStyle: Equatable {
    /// First status text. Include `{operatorName}` template parameter in the string to display operator's name.
    public var firstText: String?

    /// Font of the first status text.
    public var firstTextFont: UIFont

    /// Color of the first status text.
    public var firstTextFontColor: UIColor

    /// Text style of the first status text.
    public var firstTextStyle: UIFont.TextStyle

    /// Second status text. Include `{operatorName}` template parameter in the string to display operator's name.
    public var secondText: String?

    /// Font of the second status text.
    public var secondTextFont: UIFont

    /// Color of the second status text.
    public var secondTextFontColor: UIColor

    /// Text style of the second status text.
    public var secondTextStyle: UIFont.TextStyle

    /// Accessibility releated properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - firstText: First status text. Include `{operatorName}` template parameter in 
    ///     the string to display operator's name.
    ///   - firstTextFont: Font of the first status text.
    ///   - firstTextFontColor: Color of the first status text.
    ///   - firstTextStyle: Text style of the first status text.
    ///   - secondText: Second status text. Include `{operatorName}` template parameter in 
    ///     the string to display operator's name.
    ///   - secondTextFont: Font of the second status text.
    ///   - secondTextFontColor: Color of the second status text.
    ///   - secondTextStyle: Text style of the second status text.
    ///   - accessibility: Accessibility releated properties.
    ///
    public init(
        firstText: String?,
        firstTextFont: UIFont,
        firstTextFontColor: UIColor,
        firstTextStyle: UIFont.TextStyle,
        secondText: String?,
        secondTextFont: UIFont,
        secondTextFontColor: UIColor,
        secondTextStyle: UIFont.TextStyle,
        accessibility: Accessibility = .unsupported
    ) {
        self.firstText = firstText
        self.firstTextFont = firstTextFont
        self.firstTextFontColor = firstTextFontColor
        self.firstTextStyle = firstTextStyle
        self.secondText = secondText
        self.secondTextFont = secondTextFont
        self.secondTextFontColor = secondTextFontColor
        self.secondTextStyle = secondTextStyle
        self.accessibility = accessibility
    }
}
