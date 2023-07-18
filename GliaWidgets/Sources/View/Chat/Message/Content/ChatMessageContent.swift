import UIKit

enum ChatMessageContent {
    case text(String, accessibility: TextAccessibilityProperties)
    case files([LocalFile], accessibility: ChatFileContentView.AccessibilityProperties)
    case downloads([FileDownload], accessibility: ChatFileContentView.AccessibilityProperties)
    case choiceCard(ChoiceCard)
    case gvaPersistentButton(GvaButton)
    case attributedText(NSAttributedString, accessibility: TextAccessibilityProperties)

    struct TextAccessibilityProperties {
        let label: String
        let value: String
        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        let isFontScalingEnabled: Bool
    }
}

enum ChatMessageContentAlignment {
    case left
    case right
}
