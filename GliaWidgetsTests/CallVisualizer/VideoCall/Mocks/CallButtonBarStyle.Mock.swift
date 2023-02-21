#if DEBUG

import UIKit

extension CallButtonBarStyle {
    static let mock = Self(
        chatButton: .mock,
        videoButton: .mock,
        muteButton: .mock,
        speakerButton: .mock,
        minimizeButton: .mock,
        badge: .mock()
    )
}

extension CallButtonStyle {
    static let mock = Self(
        active: .mock,
        inactive: .mock,
        selected: .mock,
        accessibility: .unsupported
    )
}

extension CallButtonStyle.StateStyle {
    static let mock = Self(
        backgroundColor: .fill(color: .white),
        image: .mock,
        imageColor: .fill(color: .white),
        title: "",
        titleFont: .font(weight: .regular, size: 12),
        titleColor: .white,
        textStyle: .body,
        accessibility: .unsupported
    )
}

#endif
