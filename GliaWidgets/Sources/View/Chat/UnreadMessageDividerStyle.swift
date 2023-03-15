import UIKit

/// Style for divider of unread messages in secure messaging transcript.
public struct UnreadMessageDividerStyle: Equatable {
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
