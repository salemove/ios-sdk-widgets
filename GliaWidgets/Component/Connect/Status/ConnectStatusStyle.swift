import UIKit

/// Style of a connect status. These are used when visitor is in enqueued, connecting, and connected state.
public struct ConnectStatusStyle {
    /// First status text. Include `{operatorName}` template parameter in the string to display operator's name.
    public var firstText: String?

    /// Font of the first status text.
    public var firstTextFont: UIFont

    /// Color of the first status text.
    public var firstTextFontColor: UIColor

    /// Second status text. Include `{operatorName}` template parameter in the string to display operator's name.
    public var secondText: String?

    /// Font of the second status text.
    public var secondTextFont: UIFont

    /// Color of the second status text.
    public var secondTextFontColor: UIColor

    /// Accessibility releated properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - firstText: First status text. Include `{operatorName}` template parameter in the string to display operator's name.
    ///   - firstTextFont: Font of the first status text.
    ///   - firstTextFontColor: Color of the first status text.
    ///   - secondText: Second status text. Include `{operatorName}` template parameter in the string to display operator's name.
    ///   - secondTextFont: Font of the second status text.
    ///   - secondTextFontColor: Color of the second status text.
    ///   - accessibility: Accessibility releated properties.
    ///
    public init(
        firstText: String?,
        firstTextFont: UIFont,
        firstTextFontColor: UIColor,
        secondText: String?,
        secondTextFont: UIFont,
        secondTextFontColor: UIColor,
        accessibility: Accessibility = .unsupported
    ) {
        self.firstText = firstText
        self.firstTextFont = firstTextFont
        self.firstTextFontColor = firstTextFontColor
        self.secondText = secondText
        self.secondTextFont = secondTextFont
        self.secondTextFontColor = secondTextFontColor
        self.accessibility = accessibility
    }

    mutating func apply(configuration: RemoteConfiguration.EngagementState?) {
        configuration?.title?.font?.size
            .map { firstTextFont = Font.regular($0) }

        configuration?.title?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { firstTextFontColor = $0 }

        configuration?.description?.font?.size
            .map { secondTextFont = Font.regular($0) }

        configuration?.description?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { secondTextFontColor = $0 }
    }
}
