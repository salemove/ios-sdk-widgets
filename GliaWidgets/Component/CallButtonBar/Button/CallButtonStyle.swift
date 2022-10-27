import UIKit

/// Style of a button shown in call view bottom button bar (i.e. "Chat", "Video", "Mute", "Speaker" and "Minimize").
public struct CallButtonStyle {
    /// Style of a call button ("Chat", "Video", "Mute", "Speaker" and "Minimize") in a specific state - activated or not activated.
    public struct StateStyle {
        /// Background color of the button.
        public var backgroundColor: ColorType

        /// Image of the button.
        public var image: UIImage

        /// Color of the image.
        public var imageColor: ColorType

        /// Title of the button.
        public var title: String

        /// Font of the title.
        public var titleFont: UIFont

        /// Color of the title.
        public var titleColor: UIColor

        /// Text style of the title.
        public var textStyle: UIFont.TextStyle

        /// Accessibility related properties.
        public var accessibility: Accessibility
    }

    /// Style of active state.
    public var active: StateStyle

    /// Style of inactive state.
    public var inactive: StateStyle

    /// Style of selected state.
    public var selected: StateStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// Apply bar button from remote configuration
    mutating func applyBarButtonConfig(button: RemoteConfiguration.BarButtonStates?) {
        active.apply(configuration: button?.active)
        inactive.apply(configuration: button?.inactive)
        selected.apply(configuration: button?.selected)
    }
}

extension CallButtonStyle.StateStyle {
    mutating func apply(configuration: RemoteConfiguration.BarButtonStyle?) {
        configuration?.background.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }

        configuration?.imageColor.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { imageColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                imageColor = .gradient(colors: colors)
            }
        }

        configuration?.title?.alignment.map { _ in
            /// The logic for title alignment has not been implemented
        }

        configuration?.title?.background.map { _ in
            /// The logic for title background has not been implemented
        }

        UIFont.convertToFont(
            font: configuration?.title?.font,
            textStyle: textStyle
        ).map { titleFont = $0 }

        configuration?.title?.foreground.map {
            $0.value
                .map { UIColor(hex: $0) }
                .first
                .map { titleColor = $0 }
        }
    }
}
