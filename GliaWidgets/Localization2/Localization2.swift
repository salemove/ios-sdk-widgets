import Foundation

struct Localization2 {
    let callVisualizer: CallVisualizer
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
