import UIKit

/// Style of a button shown in call view bottom button bar (i.e. "Chat", "Video", "Mute", "Speaker" and "Minimize").
public struct CallButtonStyle: Equatable {
    /// Style of a call button ("Chat", "Video", "Mute", "Speaker" and "Minimize") in a specific state - activated or not activated.
    public struct StateStyle: Equatable {
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
    mutating func applyBarButtonConfig(
        button: RemoteConfiguration.BarButtonStates?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        active.apply(
            configuration: button?.active,
            assetsBuilder: assetsBuilder
        )
        inactive.apply(
            configuration: button?.inactive,
            assetsBuilder: assetsBuilder
        )
        selected.apply(
            configuration: button?.selected,
            assetsBuilder: assetsBuilder
        )
    }
}

extension CallButtonStyle.StateStyle {
    mutating func apply(
        configuration: RemoteConfiguration.BarButtonStyle?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background.unwrap {
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

        configuration?.imageColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { imageColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                imageColor = .gradient(colors: colors)
            }
        }

        configuration?.title?.alignment.unwrap { _ in
            // The logic for title alignment has not been implemented
        }

        configuration?.title?.background.unwrap { _ in
            // The logic for title background has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.title?.font),
            textStyle: textStyle
        ).unwrap { titleFont = $0 }

        configuration?.title?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }
    }
}
