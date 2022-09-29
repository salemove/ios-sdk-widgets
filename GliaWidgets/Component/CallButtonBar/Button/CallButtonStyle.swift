import UIKit

/// Style of a button shown in call view bottom button bar (i.e. "Chat", "Video", "Mute", "Speaker" and "Minimize").
public struct CallButtonStyle {
    /// Style of a call button ("Chat", "Video", "Mute", "Speaker" and "Minimize") in a specific state - activated or not activated.
    public struct StateStyle {
        /// Background color of the button.
        public var backgroundColor: UIColor

        /// Image of the button.
        public var image: UIImage

        /// Color of the image.
        public var imageColor: UIColor

        /// Title of the button.
        public var title: String

        /// Font of the title.
        public var titleFont: UIFont

        /// Color of the title.
        public var titleColor: UIColor

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
        switch configuration?.background?.type {
        case .fill:
            configuration?.background?.value
                .map { UIColor(hex: $0) }
                .first
                .map { backgroundColor = $0 }
        case .gradient, .none:

            /// The logic for gradient has not been implemented yet

            break
        }

        switch configuration?.imageColor?.type {
        case .fill:
            configuration?.imageColor?.value
                .map { UIColor(hex: $0) }
                .first
                .map { imageColor = $0 }
        case .gradient, .none:

            /// The logic for gradient has not been implemented yet

            break
        }

        configuration?.title?.alignment.map { _ in

            /// The logic for title alignment has not been implemented

        }

        configuration?.title?.background.map { _ in

            /// The logic for title background has not been implemented

        }

        UIFont.convertToFont(font: configuration?.title?.font).map {
            titleFont = $0
        }

        switch configuration?.title?.foreground?.type {
        case .fill:
            configuration?.title?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .map { titleColor = $0 }
        case .gradient, .none:

            /// The logic for gradient has not been implemented yet

            break
        }
    }
}
