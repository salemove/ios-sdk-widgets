#if DEBUG
import UIKit

extension BadgeStyle {
    static func mock(
        font: UIFont = .systemFont(ofSize: 10),
        fontColor: UIColor = .red,
        backgroundColor: UIColor = .red
    ) -> BadgeStyle {
        .init(
            font: font,
            fontColor: fontColor,
            backgroundColor: backgroundColor
        )
    }
}
#endif
