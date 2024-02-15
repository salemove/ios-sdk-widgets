import UIKit

/// Style of a download error state.
public class ChatFileDownloadErrorStateStyle {
    /// Text for the state.
    public var text: String

    /// Font of the state text.
    public var font: UIFont

    /// Color of the state text.
    public var textColor: UIColor

    /// Text style of the state text.
    public var textStyle: UIFont.TextStyle

    /// Font of the information text.
    public var infoFont: UIFont

    /// Color of the information text.
    public var infoColor: UIColor

    /// Text style of the information text.
    public var infoTextStyle: UIFont.TextStyle

    /// The text between the state text and retry text.
    public var separatorText: String

    /// Font of the separator text.
    public var separatorFont: UIFont

    /// Color of the separator text.
    public var separatorTextColor: UIColor

    /// Text style of the separator text.
    public var separatorTextStyle: UIFont.TextStyle

    /// Retry text.
    public var retryText: String

    /// Font of the retry text.
    public var retryFont: UIFont

    /// Color of the retry text.
    public var retryTextColor: UIColor

    /// Text style of the retry text.
    public var retryTextStyle: UIFont.TextStyle

    /// - Parameters:
    ///   - text: Text for the state.
    ///   - font: Font of the state text.
    ///   - textColor: Color of the state text.
    ///   - textStyle: Text style of the state text.
    ///   - infoFont: Font of the information text.
    ///   - infoColor: Color of the information text.
    ///   - infoTextStyle: Text style of the information text.
    ///   - separatorText: The text between the state text and retry text.
    ///   - separatorFont: Font of the separator text.
    ///   - separatorTextColor: Color of the separator text.
    ///   - separatorTextStyle: Text style of the separator text.
    ///   - retryText: Retry text.
    ///   - retryFont: Font of the retry text.
    ///   - retryTextColor: Color of the retry text.
    ///   - retryTextStyle: Text style of the retry text.
    ///
    public init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        textStyle: UIFont.TextStyle = .subheadline,
        infoFont: UIFont,
        infoColor: UIColor,
        infoTextStyle: UIFont.TextStyle = .caption1,
        separatorText: String,
        separatorFont: UIFont,
        separatorTextColor: UIColor,
        separatorTextStyle: UIFont.TextStyle = .footnote,
        retryText: String,
        retryFont: UIFont,
        retryTextColor: UIColor,
        retryTextStyle: UIFont.TextStyle = .subheadline
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textStyle = textStyle
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.infoTextStyle = infoTextStyle
        self.separatorText = separatorText
        self.separatorFont = separatorFont
        self.separatorTextColor = separatorTextColor
        self.separatorTextStyle = separatorTextStyle
        self.retryText = retryText
        self.retryFont = retryFont
        self.retryTextColor = retryTextColor
        self.retryTextStyle = retryTextStyle
    }
}
