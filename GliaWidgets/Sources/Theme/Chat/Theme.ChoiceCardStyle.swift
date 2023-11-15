import UIKit

public extension Theme {
    /// Style of the choice card sent to the visitor by the AI engine.
    struct ChoiceCardStyle {
        /// Style of the message text.
        public var text: Text
        /// Style of the message background.
        public var background: Layer
        /// Style of the image content.
        public var imageFile: ChatImageFileContentStyle
        /// Style of the image content.
        public var fileDownload: ChatFileDownloadStyle
        /// Style of the operator's image.
        public var operatorImage: UserImageStyle
        /// Styles of the choice card's answer options.
        public var choiceOption: Option
        /// Accessibility related properties.
        public var accessibility: Accessibility

        ///
        /// - Parameters:
        ///   - text: Style of the message text.
        ///   - background: Style of the message background.
        ///   - imageFile: Style of the image content.
        ///   - fileDownload: Style of the downloadable file content.
        ///   - operatorImage: Style of the operator's image.
        ///   - choiceOption: Styles of the choice card's answer options.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            text: Text,
            background: Layer,
            imageFile: ChatImageFileContentStyle,
            fileDownload: ChatFileDownloadStyle,
            operatorImage: UserImageStyle,
            choiceOption: Option,
            accessibility: Accessibility = .unsupported
        ) {
            self.text = text
            self.background = background
            self.imageFile = imageFile
            self.fileDownload = fileDownload
            self.operatorImage = operatorImage
            self.choiceOption = choiceOption
            self.accessibility = accessibility
        }

        mutating func apply(
            configuration: RemoteConfiguration.ResponseCard?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            background.apply(configuration: configuration?.background)

            choiceOption.apply(
                configuration: configuration?.option,
                assetsBuilder: assetsBuilder
            )

            text.apply(
                configuration: configuration?.text,
                assetsBuilder: assetsBuilder
            )

            operatorImage.apply(configuration: configuration?.userImage)
        }
    }
}

extension Theme.ChoiceCardStyle {
    /// Accessibility properties for ChoiceCardStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label for image.
        public var imageLabel: String

        ///
        /// - Parameters imageLabel: Accessibility label for image.
        public init(imageLabel: String) {
            self.imageLabel = imageLabel
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(imageLabel: "")
    }
}

public extension Theme.ChoiceCardStyle {
    struct Option {
        /// Style of an option in an active state - choice card has not been answered by the visitor yet.
        public var normal: Theme.Button
        /// Style of an option in a selected state - choice card has already been answered by the visitor.
        public var selected: Theme.Button
        /// Style of an option in a disabled state - choice card has already been answered by the visitor or the choice card became inactive (e.g. engagement ended).
        public var disabled: Theme.Button

        ///
        /// - Parameters:
        ///   - normal: Style of an option in an active state - choice card has not been answered by the visitor yet.
        ///   - selected: Style of an option in a selected state - choice card has already been answered by the visitor.
        ///   - disabled: Style of an option in a disabled state - choice card has already been answered by the visitor or the choice card became inactive (e.g. engagement ended).
        ///
        public init(
            normal: Theme.Button,
            selected: Theme.Button,
            disabled: Theme.Button
        ) {
            self.normal = normal
            self.selected = selected
            self.disabled = disabled
        }

        mutating func apply(
            configuration: RemoteConfiguration.ResponseCardOption?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            normal.apply(
                configuration: configuration?.normal,
                assetsBuilder: assetsBuilder
            )
            selected.apply(
                configuration: configuration?.selected,
                assetsBuilder: assetsBuilder
            )
            disabled.apply(
                configuration: configuration?.disabled,
                assetsBuilder: assetsBuilder
            )
        }
    }
}

extension Theme.ChoiceCardStyle {
    func toOldChoiceCardStyle() -> ChoiceCardStyle {
        return ChoiceCardStyle(
            mainText: .init(
                textFont: text.font,
                textColor: UIColor(hex: text.color),
                textStyle: text.textStyle,
                backgroundColor: background.background?.color ?? .clear,
                cornerRadius: background.cornerRadius,
                accessibility: .init(isFontScalingEnabled: text.accessibility.isFontScalingEnabled)
            ),
            frameColor: UIColor(cgColor: background.borderColor),
            borderWidth: background.borderWidth,
            cornerRadius: background.cornerRadius,
            backgroundColor: background.background?.color ?? .clear,
            imageFile: imageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            choiceOption: .init(
                normal: .init(
                    textFont: choiceOption.normal.title.font,
                    textColor: UIColor(hex: choiceOption.normal.title.color),
                    textStyle: choiceOption.normal.title.textStyle,
                    backgroundColor: choiceOption.normal.background.color,
                    borderColor: UIColor(hex: choiceOption.normal.borderColor ?? ""),
                    borderWidth: choiceOption.normal.borderWidth,
                    accessibility: .init(
                        value: choiceOption.normal.accessibility.label,
                        isFontScalingEnabled: choiceOption.normal.accessibility.isFontScalingEnabled
                    )
                ),
                selected: .init(
                    textFont: choiceOption.selected.title.font,
                    textColor: UIColor(hex: choiceOption.selected.title.color),
                    textStyle: choiceOption.selected.title.textStyle,
                    backgroundColor: choiceOption.selected.background.color,
                    borderColor: UIColor(hex: choiceOption.selected.borderColor ?? ""),
                    borderWidth: choiceOption.selected.borderWidth,
                    accessibility: .init(
                        value: choiceOption.selected.accessibility.label,
                        isFontScalingEnabled: choiceOption.selected.accessibility.isFontScalingEnabled
                    )
                ),
                disabled: .init(
                    textFont: choiceOption.disabled.title.font,
                    textColor: UIColor(hex: choiceOption.disabled.title.color),
                    textStyle: choiceOption.disabled.title.textStyle,
                    backgroundColor: choiceOption.disabled.background.color,
                    borderColor: UIColor(hex: choiceOption.disabled.borderColor ?? ""),
                    borderWidth: choiceOption.disabled.borderWidth,
                    accessibility: .init(
                        value: choiceOption.disabled.accessibility.label,
                        isFontScalingEnabled: choiceOption.disabled.accessibility.isFontScalingEnabled
                    )
                )
            ),
            accessibility: .init(imageLabel: accessibility.imageLabel)
        )
    }
}
