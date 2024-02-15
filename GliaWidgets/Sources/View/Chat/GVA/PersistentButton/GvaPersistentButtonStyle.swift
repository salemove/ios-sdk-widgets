import UIKit

/// Style of the GVA Persistent Button container
public struct GvaPersistentButtonStyle {
    /// Title of the container.
    public var title: Theme.ChatTextContentStyle

    /// Background of the container.
    public var backgroundColor: ColorType

    /// Corner radius of the container.
    public var cornerRadius: CGFloat

    /// Border width of the container.
    public var borderWidth: CGFloat

    /// Border color of the container.
    public var borderColor: UIColor

    /// Persistent Button.
    public var button: ButtonStyle

    /// - Parameters:
    ///   - title: Title of the container
    ///   - backgroundColor: Background of the container.
    ///   - cornerRadius: Corner radius of the container.
    ///   - borderWidth: Border width of the container.
    ///   - borderColor: Border color of the container.
    ///   - button: Persistent Button.
    ///
    public init(
        title: Theme.ChatTextContentStyle,
        backgroundColor: ColorType,
        cornerRadius: CGFloat,
        borderWidth: CGFloat,
        borderColor: UIColor,
        button: ButtonStyle
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.button = button
    }
}
