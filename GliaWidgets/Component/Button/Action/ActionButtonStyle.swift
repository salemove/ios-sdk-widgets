import UIKit

/// Style of an action button. This button contains a title placed on a rectangular background. Used for positive and negative actions in alerts and in the navigation bar (header) for the engagement ending button.
public struct ActionButtonStyle {
    /// Title of the button.
    public var title: String

    /// Font of the title.
    public var titleFont: UIFont

    /// Color of the title.
    public var titleColor: UIColor

    /// Background color of the button.
    public var backgroundColor: UIColor

    /// Corner radius of the button.
    public var cornerRaidus: CGFloat?

    /// Shadow offset of the button.
    public var shadowOffset: CGSize?

    /// Shadow color of the button.
    public var shadowColor: UIColor?

    /// Shadow radius of the button.
    public var shadowRadius: CGFloat?

    /// Shadow opacity of the button.
    public var shadowOpacity: Float?

    /// Border width of the button.
    public var borderWidth: CGFloat?

    /// Border color of the button.
    public var borderColor: UIColor?

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - title: Title of the button.
    ///   - titleFont: Font of the title.
    ///   - titleColor: Color of the title.
    ///   - backgroundColor: Background color of the button.
    ///   - cornerRaidus: Corner radius of the button.
    ///   - shadowOffset: Shadow offset of the button.
    ///   - shadowColor: Shadow color of the button.
    ///   - shadowRadius: Shadow radius of the button.
    ///   - shadowOpacity: Shadow opacity of the button.
    ///   - borderWidth: Border width of the button.
    ///   - borderColor: Border color of the button.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        title: String,
        titleFont: UIFont,
        titleColor: UIColor,
        backgroundColor: UIColor,
        cornerRaidus: CGFloat? = 4.0,
        shadowOffset: CGSize? = CGSize(width: 0.0, height: 2.0),
        shadowColor: UIColor? = UIColor.black,
        shadowRadius: CGFloat? = 2.0,
        shadowOpacity: Float? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: UIColor? = nil,
        accessibility: Accessibility = .unsupported
    ) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.cornerRaidus = cornerRaidus
        self.shadowOffset = shadowOffset
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.accessibility = accessibility
    }

    /// Apply Button from remote configuration
    mutating func apply(configuration: RemoteConfiguration.Button?) {
        configuration?.text?.font?.size
            .map { titleFont = Font.regular($0) }

        configuration?.text?.foreground?.value
            .map(UIColor.init(hex:))
            .first
            .map { titleColor = $0 }

        configuration?.background?.color?.value
            .map(UIColor.init(hex:))
            .first
            .map { backgroundColor = $0 }

        configuration?.background?.cornerRadius
            .map { cornerRaidus = $0 }

        configuration?.background?.borderWidth
            .map { borderWidth = $0 }

        configuration?.background?.border?.value
            .map(UIColor.init(hex:))
            .first
            .map { borderColor = $0 }

        configuration?.background?.color?.value
            .map(UIColor.init(hex:))
            .first
            .map { shadowColor = $0 }

        configuration?.shadow?.offset.map {
            shadowOffset = .init(width: $0, height: $0)
            shadowRadius = $0
        }
    }
}
