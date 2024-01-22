import Foundation

struct Localization2 {
    let callVisualizer: CallVisualizer
}

extension Localization2 {
    enum Kind {
        case live
        case mock
    }

    struct Providing {
        var provide: () -> Localization2

        func callAsFunction() -> Localization2 {
            provide()
        }
    }
}

extension Localization2 {
    struct CallVisualizer {
        var screenSharing: ScreenSharing
        var visitorCode: VisitorCode
    }
}

extension Localization2.CallVisualizer {
    struct ScreenSharing {
        let message: String
        let header: String
    }

    struct VisitorCode {
        let title: String
        let titleAccessibilityHint: String
        let closeAccessibilityHint: String
        let refreshAccessibilityHint: String
        let refreshAccessibilityLabel: String
        let failed: String
    }
}

extension Localization2.Providing {
    static let mock = Self(provide: { .mock })
}
