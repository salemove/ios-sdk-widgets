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
        public var background: String?
        /// Title style.
        public var title: Text
        /// Button corner radius.
        public var cornerRadius: CGFloat
        /// Button border width.
        public var borderWidth: CGFloat = 0
        /// Button border hex color.
        public var borderColor: String?

        public var shadow: Shadow
        /// Initializes `Button` style instance.
        public init(
            background: String?,
            title: Theme.Text,
            cornerRadius: CGFloat,
            borderWidth: CGFloat = 0,
            borderColor: String? = nil,
            shadow: Shadow = .standard
        ) {
            self.background = background
            self.title = title
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.borderColor = borderColor
            self.shadow = shadow
        }

        public init(
            acitonButtonStyle: ActionButtonStyle
        ) {
            self.background = acitonButtonStyle.backgroundColor == .clear ? nil : acitonButtonStyle.backgroundColor.hex
            self.title = .init(
                color: acitonButtonStyle.titleColor.hex,
                fontSize: acitonButtonStyle.titleFont.pointSize,
                fontWeight: acitonButtonStyle.titleFont.weight(orDefault: 0.2)
            )
            self.cornerRadius = acitonButtonStyle.cornerRaidus ?? 0
            self.borderWidth = acitonButtonStyle.borderWidth ?? 0
            self.borderColor = acitonButtonStyle.borderColor?.hex

            self.shadow = .init(
                color: acitonButtonStyle.shadowColor?.hex ?? Shadow.standard.color,
                offset: acitonButtonStyle.shadowOffset ?? Shadow.standard.offset,
                opacity: acitonButtonStyle.shadowOpacity ?? Shadow.standard.opacity,
                radius: acitonButtonStyle.shadowRadius ?? Shadow.standard.radius
            )
        }
    }

    /// Shadow style.
    public struct Shadow {
        /// Shadow color.
        public let color: String
        /// Shadow offset.
        public let offset: CGSize
        /// Shadow opacity.
        public let opacity: Float
        /// Shadow radius.
        public let radius: CGFloat

        public static let standard: Shadow = .init(
            color: "0x000000",
            offset: .init(width: 0.0, height: 2.0),
            opacity: 0.3,
            radius: 2.0
        )
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
        font: ThemeFont,
        alertStyle: AlertStyle
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
            submitButton: .init(acitonButtonStyle: alertStyle.positiveAction),
            cancellButton: .init(acitonButtonStyle: alertStyle.negativeAction),
            booleanQuestion: .default(color: color, font: font),
            scaleQuestion: .default(color: color, font: font),
            singleQuestion: .default(color: color, font: font),
            inputQuestion: .default(color: color, font: font)
        )
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
