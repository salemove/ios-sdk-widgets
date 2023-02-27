import UIKit

/// Style of a view's header (navigation bar).
public struct HeaderStyle: Equatable {
    /// Font of the title text.
    public var titleFont: UIFont

    /// Color of the title text.
    public var titleColor: UIColor

    /// Text style of the title text.
    public var textStyle: UIFont.TextStyle

    /// Background color of the view.
    public var backgroundColor: ColorType

    /// Style of the back button.
    public var backButton: HeaderButtonStyle?

    /// Style of the queue closing button.
    public var closeButton: HeaderButtonStyle

    /// Style of the engagement ending button.
    public var endButton: ActionButtonStyle

    /// Style of the screen sharing ending button.
    public var endScreenShareButton: HeaderButtonStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - titleFont: Font of the title text.
    ///   - titleColor: Color of the title text.
    ///   - backgroundColor: Background color of the view.
    ///   - backButton: Style of the back button.
    ///   - closeButton: Style of the queue closing button.
    ///   - endButton: Style of the engagement ending button.
    ///   - endScreenShareButton: Style of the screen sharing ending button.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        titleFont: UIFont,
        titleColor: UIColor,
        textStyle: UIFont.TextStyle = .title2,
        backgroundColor: ColorType,
        backButton: HeaderButtonStyle,
        closeButton: HeaderButtonStyle,
        endButton: ActionButtonStyle,
        endScreenShareButton: HeaderButtonStyle,
        accessibility: Accessibility = .unsupported
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.textStyle = textStyle
        self.backgroundColor = backgroundColor
        self.backButton = backButton
        self.closeButton = closeButton
        self.endButton = endButton
        self.endScreenShareButton = endScreenShareButton
        self.accessibility = accessibility
    }

    mutating func apply(
        configuration: RemoteConfiguration.Header?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background?.color.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { titleFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }

        configuration?.background?.border.unwrap { _ in
            // The logic for header border has not been implemented
        }

        configuration?.background?.borderWidth.unwrap { _ in
            // The logic for header borderWidth has not been implemented
        }

        configuration?.background?.cornerRadius.unwrap { _ in
            // The logic for header cornerRadius has not been implemented
        }

        configuration?.text?.alignment.unwrap { _ in
            // The logic for title alignment has not been implemented
        }

        configuration?.text?.background.unwrap { _ in
            // The logic for title background has not been implemented
        }

        backButton?.apply(configuration: configuration?.backButton)
        closeButton.apply(configuration: configuration?.closeButton)
        endButton.apply(
            configuration: configuration?.endButton,
            assetsBuilder: assetsBuilder
        )
        endScreenShareButton.apply(configuration: configuration?.endScreenSharingButton)
    }
}
