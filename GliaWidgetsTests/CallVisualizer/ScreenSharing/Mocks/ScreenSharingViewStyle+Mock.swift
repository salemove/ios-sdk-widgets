import UIKit
@testable import GliaWidgets

extension ScreenSharingViewStyle {
    static func mock() -> ScreenSharingViewStyle {
        ScreenSharingViewStyle(
            title: "",
            header: .mock(),
            messageText: "",
            messageTextFont: .systemFont(ofSize: 16),
            messageTextColor: .clear,
            buttonStyle: .mock(),
            buttonIcon: UIImage(),
            backgroundColor: .fill(color: .white),
            accessibility: .unsupported
        )
    }
}

extension HeaderStyle {
    static func mock() -> HeaderStyle {
        HeaderStyle(
            titleFont: .systemFont(ofSize: 16),
            titleColor: .cyan,
            backgroundColor: .fill(color: .clear),
            backButton: .mock(),
            closeButton: .mock(),
            endButton: .mock(),
            endScreenShareButton: .mock()
        )
    }
}

extension HeaderButtonStyle {
    static func mock() -> HeaderButtonStyle {
        HeaderButtonStyle(
            image: UIImage(),
            color: .clear
        )
    }
}

extension ActionButtonStyle {
    static func mock() -> ActionButtonStyle {
        ActionButtonStyle(
            title: "",
            titleFont: .systemFont(ofSize: 16),
            titleColor: .clear,
            backgroundColor: .fill(color: .clear)
        )
    }
}


