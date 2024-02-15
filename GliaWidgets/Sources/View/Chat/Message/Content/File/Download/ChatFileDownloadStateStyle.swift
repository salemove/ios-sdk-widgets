import UIKit

/// Style of a download state.
public class ChatFileDownloadStateStyle {
    /// Text for the state.
    public var text: String

    /// Font of the state text.
    public var font: UIFont

    /// Color of the state text.
    public var textColor: UIColor

    /// Text style of the state text.
    public var textStyle: UIFont.TextStyle

    /// Font of the file information text.
    public var infoFont: UIFont

    /// Color of the file information text.
    public var infoColor: UIColor

    /// Text style of the information text.
    public var infoTextStyle: UIFont.TextStyle

    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - textStyle: Text style of the state text.
    ///   - infoFont: Font of the file information text.
    ///   - infoColor: Color of the file information text.
    ///   - infoTextStyle: Text style of the information text.
    ///
    public init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .subheadline,
        infoFont: UIFont,
        infoColor: UIColor,
        infoTextStyle: UIFont.TextStyle = .caption1
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textStyle = textStyle
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.infoTextStyle = infoTextStyle
    }
}
