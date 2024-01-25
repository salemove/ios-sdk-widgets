import Foundation

extension Localization2 {
    static let mock = Self(
        callVisualizer: .init(
            screenSharing: .init(
                message: "Your Screen is Being Shared - Z",
                header: "Screen Sharing"
            ),
            visitorCode: .init(
                title: "Your Visitor Code",
                titleAccessibilityHint: "Shows the five-digit visitor code.",
                closeAccessibilityHint: "Closes the visitor code",
                refreshAccessibilityHint: "Generates a new visitor code",
                refreshAccessibilityLabel: "Refresh Button",
                failed: "Could not load the visitor code. Please try refreshing."
            )
        )
    )
}
