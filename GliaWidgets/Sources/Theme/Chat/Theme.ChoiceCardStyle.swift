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
    }
}
