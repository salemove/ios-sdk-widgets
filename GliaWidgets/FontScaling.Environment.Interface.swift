import UIKit

extension FontScaling {
    struct Environment {
        var fontWithNameAndSize: (String, CGFloat) -> UIFont?
        var preferredForTextStyle: (UIFont.TextStyle) -> UIFont
        var fontMetricsScaledFont: (UIFont.TextStyle, UIFont) -> UIFont
    }
}
