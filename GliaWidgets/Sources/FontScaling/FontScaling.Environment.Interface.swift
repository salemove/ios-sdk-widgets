import UIKit

extension FontScaling {
    struct Environment {
        var fontWithWeightAndSize: (CGFloat, UIFont.Weight) -> UIFont?
        var preferredForTextStyle: (UIFont.TextStyle) -> UIFont
        var fontMetricsScaledFont: (UIFont.TextStyle, UIFont) -> UIFont
    }
}
