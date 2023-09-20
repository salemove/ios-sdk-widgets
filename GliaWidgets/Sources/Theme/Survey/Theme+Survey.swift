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
            cancellButton: .init(
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

    /// Apply survey remote configuration
    mutating func apply(
        configuration: RemoteConfiguration.Survey?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        layer.apply(configuration: configuration?.layer)
        title.apply(
            configuration: configuration?.title,
            assetsBuilder: assetsBuilder
        )
        submitButton.apply(
            configuration: configuration?.submitButton,
            assetsBuilder: assetsBuilder
        )
        cancellButton.apply(
            configuration: configuration?.cancelButton,
            assetsBuilder: assetsBuilder
        )
        booleanQuestion.apply(
            configuration: configuration?.booleanQuestion,
            assetsBuilder: assetsBuilder
        )
        scaleQuestion.apply(
            configuration: configuration?.scaleQuestion,
            assetsBuilder: assetsBuilder
        )
        singleQuestion.apply(
            configuration: configuration?.singleQuestion,
            assetsBuilder: assetsBuilder
        )
        inputQuestion.apply(
            configuration: configuration?.inputQuestion,
            assetsBuilder: assetsBuilder
        )
    }
}
