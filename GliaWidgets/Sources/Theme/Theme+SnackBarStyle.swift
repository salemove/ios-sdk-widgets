import UIKit

extension Theme {
    var snackBarStyle: SnackBarStyle {
        .init(
            background: color.baseDark,
            textColor: color.baseLight,
            textFont: .font(weight: .regular, size: 17),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }

    var invertedSnackBarStyle: SnackBarStyle {
        .init(
            background: color.baseLight,
            textColor: color.baseDark,
            textFont: .font(weight: .regular, size: 17),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }

    public struct SnackBarStyle: Equatable {
        /// View's background color
        public var background: UIColor
        /// Snack message text color.
        public var textColor: UIColor
        /// Snack message text font.
        public var textFont: UIFont
        /// Style accessibility.
        public var accessibility: Accessibility
    }
}

extension Theme.SnackBarStyle {
    mutating func apply(
        configuration: RemoteConfiguration.SnackBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.text?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap { textColor = $0 }

        configuration?.background?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap { background = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(.init(size: 17, style: .regular)),
            textStyle: .title3
        ).unwrap { textFont = $0 }
    }

    /// Accessibility properties for Text.
    public struct Accessibility: Equatable {
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(isFontScalingEnabled: Bool) {
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(isFontScalingEnabled: false)
    }
}
