import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for title icon image.
    public struct TitleImageStyle: Equatable {
        /// Color of the image.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameter color: Color of the image.
        public init(
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.color = color
            self.accessibility = accessibility
        }

        /// Accessibility properties for TitleImageStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }

        mutating func apply(
            configuration: RemoteConfiguration.Color?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            configuration?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { color = $0 }
        }
    }
}
