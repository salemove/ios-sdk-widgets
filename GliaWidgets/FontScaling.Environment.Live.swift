import UIKit

extension FontScaling.Environment {
    static let live = Self(
        fontWithNameAndSize: FontProvider.shared.optionalFont(named:size:),
        preferredForTextStyle: UIFont.preferredFont(forTextStyle:),
        fontMetricsScaledFont: { style, font in
            UIFontMetrics(forTextStyle: style)
                .scaledFont(for: font)
        }
    )
}
