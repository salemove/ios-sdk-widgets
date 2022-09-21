import Foundation
import UIKit

extension Theme {

    public struct SurveyStyle {
        /// Layer style.
        public var layer: Layer
        /// Header text style.
        public var title: Text
        /// Submit button style.
        public var submitButton: Button
        /// Cancell button style.
        public var cancellButton: Button
        /// "Boolean" question view style.
        public var booleanQuestion: BooleanQuestion
        /// "Scale" question view style.
        public var scaleQuestion: ScaleQuestion
        /// "Single" question view style.
        public var singleQuestion: SingleQuestion
        /// "Input" question view style.
        public var inputQuestion: InputQuestion
        /// Accessibility related properties.
        public var accessibility: Accessibility
        /// Initializes `SurveyStyle` instance.
        public init(
            layer: Theme.Layer,
            title: Theme.Text,
            submitButton: Theme.Button,
            cancellButton: Theme.Button,
            booleanQuestion: Theme.SurveyStyle.BooleanQuestion,
            scaleQuestion: Theme.SurveyStyle.ScaleQuestion,
            singleQuestion: Theme.SurveyStyle.SingleQuestion,
            inputQuestion: Theme.SurveyStyle.InputQuestion,
            accessibility: Accessibility
        ) {
            self.layer = layer
            self.title = title
            self.submitButton = submitButton
            self.cancellButton = cancellButton
            self.booleanQuestion = booleanQuestion
            self.scaleQuestion = scaleQuestion
            self.singleQuestion = singleQuestion
            self.inputQuestion = inputQuestion
            self.accessibility = accessibility
        }
    }
}

extension Theme.SurveyStyle {
    public static func `default`(
        color: ThemeColor,
        font: ThemeFont,
        alertStyle: AlertStyle
    ) -> Self {

        let font = ThemeFontStyle.default.font

        return .init(
            layer: .init(
                background: color.background.hex,
                borderColor: color.baseDark.hex,
                cornerRadius: 30
            ),
            title: .init(
                color: color.baseNormal.hex,
                font: font.header2
            ),
            submitButton: .init(
                acitonButtonStyle: alertStyle.positiveAction,
                accessibility: .init(label: L10n.Survey.Accessibility.Footer.SubmitButton.label)
            ),
            cancellButton: .init(
                acitonButtonStyle: alertStyle.negativeAction,
                accessibility: .init(label: L10n.Survey.Accessibility.Footer.CancelButton.label)
            ),
            booleanQuestion: .default(color: color, font: font),
            scaleQuestion: .default(color: color, font: font),
            singleQuestion: .default(color: color, font: font),
            inputQuestion: .default(color: color, font: font),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }

    /// Apply survey remote configuration
    public mutating func applySurveyConfiguration(_ survey: RemoteConfiguration.Survey?) {
        layer.applyLayerConfiguration(survey?.layer)
        title.applyTextConfiguration(survey?.title)
        submitButton.applyQuestionConfiguration(survey?.submitButton)
        cancellButton.applyQuestionConfiguration(survey?.cancelButton)
        booleanQuestion.applyQuestionConfiguration(survey?.booleanQuestion)
        scaleQuestion.applyQuestionConfiguration(survey?.scaleQuestion)
        singleQuestion.applyQuestionConfiguration(survey?.singleQuestion)
        inputQuestion.applyQuestionConfiguration(survey?.inputQuestion)
    }
}

extension UIFont {
    func weight(orDefault defaultValue: CGFloat) -> CGFloat {
        guard let face = fontDescriptor.object(forKey: .face) as? String else { return defaultValue }
        switch face.lowercased() {
        case "bold":    return 0.5
        case "thin":    return 0.05
        default:        return 0.2
        }
    }
}
