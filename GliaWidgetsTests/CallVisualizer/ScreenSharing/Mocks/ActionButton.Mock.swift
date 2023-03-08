#if DEBUG

import UIKit

extension ActionButton.Props {
    static func mock(
        style: ActionButtonStyle = .mock(),
        height: CGFloat = 40,
        tap: Cmd = .nop,
        accessibilityIdentifier: String = ""
    ) -> ActionButton.Props {
        return .init(
            style: style,
            height: height,
            tap: tap,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }
}

#endif
