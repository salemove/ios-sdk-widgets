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
    mutating func applyBadgeConfiguration(_ badge: RemoteConfiguration.BadgeStyle?) {
        UIFont.convertToFont(font: badge?.font).map {
            font = $0
        }

        badge?.fontColor?.value.map {
            fontColor = UIColor(hex: $0[0])
        }

        badge?.backgroundColor?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                badge?.backgroundColor?.value.map {
                    backgroundColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }
    }
}
