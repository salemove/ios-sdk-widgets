import UIKit

struct FontScaling {
    var descriptions: [Style: Description]
    var environment: Environment

    func uiFont(with textStyle: UIFont.TextStyle, fontSize: CGFloat? = nil) -> UIFont {
        guard
            let style = Style(textStyle),
            let description = descriptions[style],
            let uiFont = environment.fontWithNameAndSize(description.name, fontSize ?? description.size) else {
                return environment.preferredForTextStyle(textStyle)
            }

        return environment.fontMetricsScaledFont(textStyle, uiFont)
    }
}

extension FontScaling {
    enum Style: String, CaseIterable {
        case body,
             callout,
             caption1,
             caption2,
             footnote,
             headline,
             largeTitle,
             subheadline,
             title1,
             title2,
             title3
    }

    struct Description {
        let name: String
        let size: Double
    }
}

extension FontScaling.Style {
    init?(_ textStyle: UIFont.TextStyle) {
        switch textStyle {
        case .body: self = .body
        case .callout: self = .callout
        case .caption1: self = .caption1
        case .caption2: self = .caption2
        case .footnote: self = .footnote
        case .headline: self = .headline
        case .largeTitle: self = .largeTitle
        case .subheadline: self = .subheadline
        case .title1: self = .title1
        case .title2: self = .title2
        case .title3: self = .title3
        default: return nil
        }
    }
}

// Set of free functions to assign `adjustsFontForContentSizeCategory` value to view components.

func setFontScalingEnabled(_ enabled: Bool, for label: UILabel) {
    label.adjustsFontForContentSizeCategory = enabled
}

func setFontScalingEnabled(_ enabled: Bool, for textView: UITextView) {
    textView.adjustsFontForContentSizeCategory = enabled
}

func setFontScalingEnabled(_ enabled: Bool, for textField: UITextField) {
    textField.adjustsFontForContentSizeCategory = enabled
}

func setFontScalingEnabled(_ enabled: Bool, for button: UIButton) {
    button.titleLabel?.adjustsFontForContentSizeCategory = enabled
    if #available(iOS 15.0, *) {
        button.subtitleLabel?.adjustsFontForContentSizeCategory = enabled
    }
}
