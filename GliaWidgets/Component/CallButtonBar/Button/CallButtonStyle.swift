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

    /// Style of active (i.e. toggled "on") state.
    public var active: StateStyle

    /// Style of inactive (i.e. toggled "off") state.
    public var inactive: StateStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// Apply bar button from remote configuration
    mutating func applyBarButtonConfig(button: RemoteConfiguration.BarButtonStates?) {
        applyActiveBarButtonConfiguration(button: button)
        applyActiveBarButtonConfiguration(button: button)
    }

    private mutating func applyActiveBarButtonConfiguration(button: RemoteConfiguration.BarButtonStates?) {
        button?.active?.background?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                button?.active?.background?.value.map {
                    active.backgroundColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented yet

                break
            }
        }

        button?.active?.imageColor?.type.map { imageType in
            switch imageType {
            case .fill:
                button?.active?.imageColor?.value.map {
                    active.imageColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented yet

                break
            }
        }

        button?.active?.title?.alignment.map { _ in

        /// The logic for title alignment has not been implemented

        }

        button?.active?.title?.background.map { _ in

        /// The logic for title background has not been implemented

        }

        UIFont.convertToFont(font: button?.active?.title?.font).map {
            active.titleFont = $0
        }

        button?.active?.title?.foreground?.type.map { foregroundType in
            switch foregroundType {
            case .fill:
                button?.active?.imageColor?.value.map {
                    active.imageColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented yet

                break
            }
        }
    }

    private mutating func applyInactiveBarButtonConfiguration(button: RemoteConfiguration.BarButtonStates?) {
        button?.inactive?.background?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                button?.inactive?.background?.value.map {
                    inactive.backgroundColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        button?.inactive?.imageColor?.type.map { imageType in
            switch imageType {
            case .fill:
                button?.inactive?.imageColor?.value.map {
                    inactive.imageColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        button?.inactive?.title?.alignment.map { _ in

        /// The logic for title alignment has not been implemented

        }

        button?.inactive?.title?.background.map { _ in

        /// The logic for title background has not been implemented

        }

        UIFont.convertToFont(font: button?.inactive?.title?.font).map {
            inactive.titleFont = $0
        }

        button?.inactive?.title?.foreground?.type.map { foregroundType in
            switch foregroundType {
            case .fill:
                button?.inactive?.imageColor?.value.map {
                    inactive.imageColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }
    }
}
