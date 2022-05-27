#if DEBUG
import UIKit

extension FontScaling.Environment {
    static let mock = Self(
        fontWithNameAndSize: { _, _ in nil },
        preferredForTextStyle: { _ in .systemFont(ofSize: .pi) },
        fontMetricsScaledFont: { _, _ in .systemFont(ofSize: .pi) }
    )
}
#endif
