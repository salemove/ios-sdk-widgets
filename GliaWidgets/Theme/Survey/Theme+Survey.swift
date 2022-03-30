import Foundation
import UIKit

public extension Theme {
    /// Text style.
    struct Text {
        /// Foreground hex color.
        public var color: String
        /// Font size.
        public var fontSize: CGFloat
        /// Font weight.
        public var fontWeight: CGFloat
    }

    /// Button style.
    struct Button {
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
    }

    /// Abstract layer style.
    struct Layer {
        /// Background hex color.
        public var background: String?
        /// Border hex color.
        public var borderColor: String
        /// Border width.
        public var borderWidth: CGFloat = 0
        /// Layer corner radius.
        public var cornerRadius: CGFloat = 0
    }

    struct SurveyStyle {
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
    }
}

public extension Theme.SurveyStyle {
    /// Survey option button style.
    struct OptionButton {
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
    }
}

extension Theme.SurveyStyle {
    static func make(
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
