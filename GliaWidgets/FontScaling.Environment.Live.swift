import UIKit

extension FontScaling.Environment {
    static let live = Self(
        fontWithWeightAndSize: UIFont.systemFont(ofSize:weight:),
        preferredForTextStyle: UIFont.preferredFont(forTextStyle:),
        fontMetricsScaledFont: { style, font in
            UIFontMetrics(forTextStyle: style)
                .scaledFont(for: font)
        }
    )
}
