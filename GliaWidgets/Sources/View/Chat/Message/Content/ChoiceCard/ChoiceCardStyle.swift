import UIKit

/// Deprecated. Style of the choice card sent to the visitor by the AI engine.
@available(*, deprecated, message: "Deprecated, use ``Theme.ChoiceCardStyle`` instead.")
public final class ChoiceCardStyle: OperatorChatMessageStyle {
    /// Color of the choice card's border.
    public var frameColor: UIColor

    /// Width of the choice card's border.
    public var borderWidth: CGFloat

    /// Corner radius of the choice card.
    public var cornerRadius: CGFloat

    /// Background color of t the choice card.
    public var backgroundColor: UIColor

    /// Styles of the choice card's answer options.
    public var choiceOption: ChoiceCardOptionStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - mainText: Style of the choice card's main text.
    ///   - frameColor: Color of the choice card's border.
    ///   - imageFile: Style of a choice card's image.
    ///   - fileDownload: Style of a choice card's attached files.
    ///   - operatorImage: Style of the operator's image to the left of a choice card.
    ///   - choiceOption: Styles of the choice card's answer options.
    ///   - accessibility: Accessibility related properties.
    public init(
        mainText: ChatTextContentStyle,
        frameColor: UIColor,
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 8,
        backgroundColor: UIColor,
        imageFile: ChatImageFileContentStyle,
        fileDownload: ChatFileDownloadStyle,
        operatorImage: UserImageStyle,
        choiceOption: ChoiceCardOptionStyle,
        accessibility: Accessibility
    ) {
        self.frameColor = frameColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.choiceOption = choiceOption
        self.accessibility = accessibility
        super.init(
            text: mainText,
            imageFile: imageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage
        )
    }

    func apply(
        configuration: RemoteConfiguration.ResponseCard?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { frameColor = $0 }

        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        choiceOption.apply(
            configuration: configuration?.option,
            assetsBuilder: assetsBuilder
        )

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: text.textStyle
        ).unwrap { text.textFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { text.textColor = $0 }

        operatorImage.apply(configuration: configuration?.userImage)
    }

    // swiftlint:disable function_body_length
    func toNewChoiceCardStyle() -> Theme.ChoiceCardStyle {
        .init(
            text: .init(
                color: text.textColor.hex,
                font: text.textFont,
                textStyle: text.textStyle,
                accessibility: .init(isFontScalingEnabled: text.accessibility.isFontScalingEnabled)
            ),
            background: .init(
                background: .fill(color: backgroundColor),
                borderColor: .clear,
                borderWidth: .zero,
                cornerRadius: cornerRadius
            ),
            imageFile: imageFile,
            fileDownload: fileDownload,
            operatorImage: operatorImage,
            choiceOption: .init(
                normal: .init(
                    background: .fill(color: choiceOption.normal.backgroundColor),
                    title: .init(
                        color: choiceOption.normal.textColor.hex,
                        font: choiceOption.normal.textFont,
                        textStyle: choiceOption.normal.textStyle,
                        accessibility: .init(isFontScalingEnabled: choiceOption.normal.accessibility.isFontScalingEnabled)
                    ),
                    cornerRadius: choiceOption.normal.cornerRadius,
                    borderWidth: choiceOption.normal.borderWidth,
                    borderColor: choiceOption.normal.borderColor?.hex,
                    accessibility: .init(
                        label: choiceOption.normal.accessibility.value,
                        isFontScalingEnabled: choiceOption.normal.accessibility.isFontScalingEnabled
                    )
                ),
                selected: .init(
                    background: .fill(color: choiceOption.selected.backgroundColor),
                    title: .init(
                        color: choiceOption.selected.textColor.hex,
                        font: choiceOption.selected.textFont,
                        textStyle: choiceOption.selected.textStyle,
                        accessibility: .init(isFontScalingEnabled: choiceOption.selected.accessibility.isFontScalingEnabled)
                    ),
                    cornerRadius: choiceOption.selected.cornerRadius,
                    borderWidth: choiceOption.selected.borderWidth,
                    borderColor: choiceOption.selected.borderColor?.hex,
                    accessibility: .init(
                        label: choiceOption.selected.accessibility.value,
                        isFontScalingEnabled: choiceOption.selected.accessibility.isFontScalingEnabled
                    )
                ),
                disabled: .init(
                    background: .fill(color: choiceOption.disabled.backgroundColor),
                    title: .init(
                        color: choiceOption.disabled.textColor.hex,
                        font: choiceOption.disabled.textFont,
                        textStyle: choiceOption.disabled.textStyle,
                        accessibility: .init(isFontScalingEnabled: choiceOption.disabled.accessibility.isFontScalingEnabled)
                    ),
                    cornerRadius: choiceOption.disabled.cornerRadius,
                    borderWidth: choiceOption.disabled.borderWidth,
                    borderColor: choiceOption.disabled.borderColor?.hex,
                    accessibility: .init(
                        label: choiceOption.disabled.accessibility.value,
                        isFontScalingEnabled: choiceOption.disabled.accessibility.isFontScalingEnabled
                    )
                )
            ),
            accessibility: .init(imageLabel: accessibility.imageLabel)
        )
    }
    // swiftlint:enable function_body_length
}
