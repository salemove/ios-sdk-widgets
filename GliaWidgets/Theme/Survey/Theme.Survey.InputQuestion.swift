import Foundation

public extension Theme.SurveyStyle {
    struct InputQuestion {
        public var title: Theme.Text
        public var option: OptionButton

        static func `default`(
            color: ThemeColor,
            font: ThemeFont
        ) -> Self {
            .init(
                title: .init(
                    color: color.baseDark.hex,
                    fontSize: font.bodyText.pointSize,
                    fontWeight: 0.4
                ),
                option: .init(
                    normalText: .init(
                        color: color.baseDark.hex,
                        fontSize: font.bodyText.pointSize,
                        fontWeight: 0.3
                    ),
                    normalLayer: .init(
                        borderColor: color.baseNormal.hex,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    selectedText: .init(
                        color: color.baseLight.hex,
                        fontSize: font.bodyText.pointSize,
                        fontWeight: 0.3
                    ),
                    selectedLayer: .init(
                        background: color.primary.hex,
                        borderColor: "",
                        borderWidth: 0,
                        cornerRadius: 4
                    ),
                    highlightedText: .init(
                        color: color.systemNegative.hex,
                        fontSize: font.bodyText.pointSize,
                        fontWeight: 0.3
                    ),
                    highlightedLayer: .init(
                        borderColor: color.systemNegative.hex,
                        borderWidth: 1,
                        cornerRadius: 4
                    )
                )
            )
        }
    }
}
