import Foundation
import UIKit

extension Theme {
    /// Text style.
    public struct Text {
        /// Foreground hex color.
        public var color: String
        /// Font size.
        public var fontSize: CGFloat
        /// Font weight.
        public var fontWeight: CGFloat
        /// Initializes `Text` style instance.
        public init(
            color: String,
            fontSize: CGFloat,
            fontWeight: CGFloat
        ) {
            self.color = color
            self.fontSize = fontSize
            self.fontWeight = fontWeight
        }
    }

    /// Button style.
    public struct Button {
        /// Background hex color.
        public var background: String
        /// Title style.
        public var title: Text
        /// Button corner radius.
        public var cornerRadius: CGFloat
        /// Button border width.
        public var borderWidth: CGFloat = 0
        /// Button border hex color.
        public var borderColor: String?
        /// Initializes `Button` style instance.
        public init(
            background: String,
            title: Theme.Text,
            cornerRadius: CGFloat,
            borderWidth: CGFloat = 0,
            borderColor: String? = nil
        ) {
            self.background = background
            self.title = title
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.borderColor = borderColor
        }
    }

    /// Abstract layer style.
    public struct Layer {
        /// Background hex color.
        public var background: String?
        /// Border hex color.
        public var borderColor: String
        /// Border width.
        public var borderWidth: CGFloat = 0
        /// Layer corner radius.
        public var cornerRadius: CGFloat = 0
        /// Initializes `Layer` style instance.
        public init(
            background: String? = nil,
            borderColor: String,
            borderWidth: CGFloat = 0,
            cornerRadius: CGFloat = 0
        ) {
            self.background = background
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
        }
    }

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
        /// Initializes `SurveyStyle` instance.
        public init(
            layer: Theme.Layer,
            title: Theme.Text,
            submitButton: Theme.Button,
            cancellButton: Theme.Button,
            booleanQuestion: Theme.SurveyStyle.BooleanQuestion,
            scaleQuestion: Theme.SurveyStyle.ScaleQuestion,
            singleQuestion: Theme.SurveyStyle.SingleQuestion,
            inputQuestion: Theme.SurveyStyle.InputQuestion
        ) {
            self.layer = layer
            self.title = title
            self.submitButton = submitButton
            self.cancellButton = cancellButton
            self.booleanQuestion = booleanQuestion
            self.scaleQuestion = scaleQuestion
            self.singleQuestion = singleQuestion
            self.inputQuestion = inputQuestion
        }
    }
}

extension Theme.SurveyStyle {
    /// Survey option button style.
    public struct OptionButton {
        /// Title text for normal state.
        public var normalText: Theme.Text
        /// Option layer for normal state.
        public var normalLayer: Theme.Layer
        /// Title text style when option is selected.
        public var selectedText: Theme.Text
        /// Layer style when option is selected.
        public var selectedLayer: Theme.Layer
        /// Title text style when option is highlighted.
        public var highlightedText: Theme.Text
        /// Layer style when option is highlighted.
        public var highlightedLayer: Theme.Layer
        /// Initializes `OptionButton` style instance.
        public init(
            normalText: Theme.Text,
            normalLayer: Theme.Layer,
            selectedText: Theme.Text,
            selectedLayer: Theme.Layer,
            highlightedText: Theme.Text,
            highlightedLayer: Theme.Layer
        ) {
            self.normalText = normalText
            self.normalLayer = normalLayer
            self.selectedText = selectedText
            self.selectedLayer = selectedLayer
            self.highlightedText = highlightedText
            self.highlightedLayer = highlightedLayer
        }
    }
}

extension Theme.SurveyStyle {
    public static func `default`(
        color: ThemeColor,
        font: ThemeFont
    ) -> Self {

        return .init(
            layer: .init(
                background: color.background.hex,
                borderColor: color.baseDark.hex,
                cornerRadius: 30
            ),
            title: .init(
                color: color.baseNormal.hex,
                fontSize: 20,
                fontWeight: 0.3
            ),
            submitButton: .init(
                background: color.primary.hex,
                title: .init(color: color.baseLight.hex, fontSize: 16, fontWeight: 0.1),
                cornerRadius: 4
            ),
            cancellButton: .init(
                background: color.systemNegative.hex,
                title: .init(color: color.baseLight.hex, fontSize: 16, fontWeight: 0.1),
                cornerRadius: 4
            ),
            booleanQuestion: .default(color: color, font: font),
            scaleQuestion: .default(color: color, font: font),
            singleQuestion: .default(color: color, font: font),
            inputQuestion: .default(color: color, font: font)
        )
    }
}
