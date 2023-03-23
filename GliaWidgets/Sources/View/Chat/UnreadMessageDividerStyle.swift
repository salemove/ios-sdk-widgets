import UIKit

/// Style for divider of unread messages in secure messaging transcript.
public class UnreadMessageDividerStyle: Equatable {
    /// Message divider title.
    public var title: String
    /// Text color for message divider title.
    public var titleColor: UIColor
    /// Font for message divider title.
    public var titleFont: UIFont
    /// Line color for message divider.
    public var lineColor: UIColor
    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - title: Message divider title.
    ///   - titleColor: Text color for message divider title.
    ///   - titleFont: Font for message divider title.
    ///   - lineColor: Line color for message divider.
    ///   - accessibility: Accessibility properties for UnreadMessageDividerStyle.
    public init(
        title: String,
        titleColor: UIColor,
        titleFont: UIFont,
        lineColor: UIColor,
        accessibility: Accessibility
    ) {
        self.title = title
        self.lineColor = lineColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.accessibility = accessibility
    }

    public static func == (lhs: UnreadMessageDividerStyle, rhs: UnreadMessageDividerStyle) -> Bool {
        return lhs.title == rhs.title &&
        lhs.titleColor == rhs.titleColor &&
        lhs.titleFont == rhs.titleFont &&
        lhs.lineColor == rhs.lineColor
    }
}

extension UnreadMessageDividerStyle {
    /// Accessibility properties for UnreadMessageDividerStyle.
    public struct Accessibility: Equatable {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            isFontScalingEnabled: Bool
        ) {
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            isFontScalingEnabled: false
        )
    }
}

extension UnreadMessageDividerStyle {
    func apply(
        lineColor: RemoteConfiguration.Color?,
        text: RemoteConfiguration.Text?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        lineColor?.value.map { UIColor(hex: $0) }
            .first
            .unwrap { self.lineColor = $0 }

        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(text?.font),
            textStyle: .body
        ).unwrap { titleFont = $0 }

        text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }
    }
}
