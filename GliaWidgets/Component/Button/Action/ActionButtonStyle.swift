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

    /// Apply actionButton from remote configuration
    mutating func applyActionButtonCustomization(_ button: RemoteConfiguration.ActionButton?) {
        applyTitleCustomization(button?.title)
        applyBackgroundCustomization(button?.background)
    }

    /// Apply button title from remote configuration
    private mutating func applyTitleCustomization(_ title: RemoteConfiguration.Text?) {
        UIFont.convertToFont(font: title?.font).map {
            titleFont = $0
        }

        title?.foreground?.value.map {
            titleColor = UIColor(hex: $0[0])
        }
    }

    /// Apply button background from remote configuration
    private mutating func applyBackgroundCustomization(_ background: RemoteConfiguration.Layer?) {
        background?.color?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                background?.color?.value.map {
                    backgroundColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        background?.border?.type.map { borderType in
            switch borderType {
            case .fill:
                background?.border?.value.map {
                    borderColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        background?.borderWidth.map {
            borderWidth = $0
        }

        background?.cornerRadius.map {
            cornerRaidus = CGFloat($0)
        }
    }

    /// Apply shadow from remote configuration
    private mutating func applyShadowCustomization(_ shadow: RemoteConfiguration.Shadow?) {
        shadow?.offset.map {
            shadowOffset = CGSize(width: $0, height: $0)
        }

        shadow?.radius.map {
            shadowRadius = CGFloat($0)
        }

        shadow?.opacity.map {
            shadowOpacity = Float($0)
        }

        shadow?.color?.type.map { colorType in
            switch colorType {
            case .fill:
                shadow?.color?.value.map {
                    shadowColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }
    }
}
