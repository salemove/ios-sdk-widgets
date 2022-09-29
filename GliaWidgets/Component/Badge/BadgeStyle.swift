import UIKit

/// Style of a badge view. A badge is used to show unread message count on the minimized bubble and on the chat button in the call view.
public struct BadgeStyle {
    /// Font of the text.
    public var font: UIFont

    /// Color of the text.
    public var fontColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - font: Font of the text.
    ///   - fontColor: Color of the text.
    ///   - backgroundColor: Background color of the view.
    ///
    public init(
        font: UIFont,
        fontColor: UIColor,
        backgroundColor: UIColor
    ) {
        self.font = font
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
    }

    /// Apply badge remote configuration
    mutating func apply(configuration: RemoteConfiguration.Button?) {
        UIFont.convertToFont(font: configuration?.text?.font).map {
            font = $0
        }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { fontColor = $0 }

        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .map { backgroundColor = $0 }
    }
}
