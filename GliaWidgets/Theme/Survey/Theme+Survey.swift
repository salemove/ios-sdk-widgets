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
                background: .fill(color: color.background),
                borderColor: color.baseDark.cgColor,
                cornerRadius: 30
            ),
            title: .init(
                color: color.baseNormal.hex,
                font: font.header2,
                textStyle: .title2
            ),
            submitButton: .init(
                actionButtonStyle: alertStyle.positiveAction,
                accessibility: .init(label: L10n.Survey.Accessibility.Footer.SubmitButton.label)
            ),
            cancellButton: .init(
                actionButtonStyle: alertStyle.negativeAction,
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
    mutating func apply(configuration: RemoteConfiguration.Survey?) {
        layer.apply(configuration: configuration?.layer)
        title.apply(configuration: configuration?.title)
        submitButton.apply(configuration: configuration?.submitButton)
        cancellButton.apply(configuration: configuration?.cancelButton)
        booleanQuestion.apply(configuration: configuration?.booleanQuestion)
        scaleQuestion.apply(configuration: configuration?.scaleQuestion)
        singleQuestion.apply(configuration: configuration?.singleQuestion)
        inputQuestion.apply(configuration: configuration?.inputQuestion)
    }
}
