import UIKit

extension Theme {
    public struct SnackBarStyle: Equatable {
        /// SnackBar message text.
        public var text: String

        /// View's background color.
        public var background: UIColor

        /// Snack message text color.
        public var textColor: UIColor

        /// Snack message text font.
        public var textFont: UIFont

        /// Style accessibility.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: SnackBar message text.
        ///   - background: View's background color.
        ///   - textColor: Snack message text color.
        ///   - textFont: Snack message text font.
        ///   - accessibility: Style accessibility.
        ///
        public init(
            text: String,
            background: UIColor,
            textColor: UIColor,
            textFont: UIFont,
            accessibility: Accessibility
        ) {
            self.text = text
            self.background = background
            self.textColor = textColor
            self.textFont = textFont
            self.accessibility = accessibility
        }
    }
}

extension Theme {
    var snackBarStyle: SnackBarStyle {
        .init(
            text: Localization.LiveObservation.Indicator.message,
            background: color.baseDark,
            textColor: color.baseLight,
            textFont: .font(weight: .regular, size: 17),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }

    var invertedSnackBarStyle: SnackBarStyle {
        .init(
            text: Localization.LiveObservation.Indicator.message,
            background: color.baseLight,
            textColor: color.baseDark,
            textFont: .font(weight: .regular, size: 17),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
