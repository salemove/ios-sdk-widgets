import UIKit

extension Theme {
    public struct SurveyStyle {
        /// Layer style.
        public var layer: Layer

        /// Header text style.
        public var title: Text

        /// Submit button style.
        public var submitButton: Button

        /// Cancel button style.
        public var cancelButton: Button

        /// Deprecated cancel button style
        @available(*, deprecated, message: "Use ``cancelButton`` instead")
        public var cancellButton: Button { cancelButton }

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

        /// - Parameters:
        ///   - layer: Layer style.
        ///   - title: Header text style.
        ///   - submitButton: Submit button style.
        ///   - cancelButton: Cancel button style.
        ///   - booleanQuestion: "Boolean" question view style.
        ///   - scaleQuestion: "Scale" question view style.
        ///   - singleQuestion: "Single" question view style.
        ///   - inputQuestion: "Input" question view style.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            layer: Theme.Layer,
            title: Theme.Text,
            submitButton: Theme.Button,
            cancelButton: Theme.Button,
            booleanQuestion: Theme.SurveyStyle.BooleanQuestion,
            scaleQuestion: Theme.SurveyStyle.ScaleQuestion,
            singleQuestion: Theme.SurveyStyle.SingleQuestion,
            inputQuestion: Theme.SurveyStyle.InputQuestion,
            accessibility: Accessibility
        ) {
            self.layer = layer
            self.title = title
            self.submitButton = submitButton
            self.cancelButton = cancelButton
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
                background: .fill(color: color.baseLight),
                borderColor: color.baseDark.cgColor,
                cornerRadius: 30
            ),
            title: .init(
                color: color.baseNormal.hex,
                font: font.header2,
                textStyle: .title2,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            submitButton: .init(
                actionButtonStyle: alertStyle.positiveAction,
                accessibility: .init(
                    label: Localization.General.submit,
                    isFontScalingEnabled: true
                )
            ),
            cancelButton: .init(
                actionButtonStyle: alertStyle.negativeAction,
                accessibility: .init(
                    label: Localization.General.cancel,
                    isFontScalingEnabled: true
                )
            ),
            booleanQuestion: .default(color: color, font: font),
            scaleQuestion: .default(color: color, font: font),
            singleQuestion: .default(color: color, font: font),
            inputQuestion: .default(color: color, font: font),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
