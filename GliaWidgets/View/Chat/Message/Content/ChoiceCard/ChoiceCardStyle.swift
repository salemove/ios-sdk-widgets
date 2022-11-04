import UIKit

/// Style of the choice card sent to the visitor by the AI engine.
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

    func apply(configuration: RemoteConfiguration.ResponseCard?) {
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

        choiceOption.apply(configuration: configuration?.option)
        apply(configuration: configuration?.message)
    }
}
