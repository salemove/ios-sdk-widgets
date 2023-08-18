import Foundation
import UIKit

extension Theme {
    /// Text style.
    public struct Text: Equatable {
        /// Foreground hex color.
        public var color: String
        /// Font.
        public var font: UIFont
        /// Text style.
        public var textStyle: UIFont.TextStyle
        /// Text aligmment.
        public var alignment: NSTextAlignment
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// Initializes `Text` style instance.
        public init(
            color: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            alignment: NSTextAlignment = .center,
            accessibility: Accessibility
        ) {
            self.color = color
            self.font = font
            self.textStyle = textStyle
            self.alignment = alignment
            self.accessibility = accessibility
        }

        /// Apply text from remote configuration
        mutating func apply(
            configuration: RemoteConfiguration.Text?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            configuration?.alignment.unwrap { alignment in
                switch alignment {
                case .center:
                    self.alignment = .center
                case .leading:
                    self.alignment = .left
                case .trailing:
                    self.alignment = .right
                }
            }

            configuration?.background.unwrap { _ in
                // The logic for normal text background has not been implemented
            }

            UIFont.convertToFont(
                uiFont: assetsBuilder.fontBuilder(configuration?.font),
                textStyle: textStyle
            ).unwrap { font = $0 }

            configuration?.foreground?.value
                .first
                .unwrap { color = $0 }
        }
    }
}

extension Theme.Text {
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
