import Foundation

extension Localization2 {
    static func live(stringProviding: @escaping () -> StringProvidingPhase?) -> Self {
        .init(callVisualizer: .init(
            screenSharing: .init(
                message: Localization2.tr(
                    "Localizable",
                    "call_visualizer.screen_sharing.message",
                    fallback: "Your Screen is Being Shared",
                    stringProviding: stringProviding
                ),
                header: Localization2.tr(
                    "Localizable",
                    "call_visualizer.screen_sharing.header.title",
                    fallback: "Screen Sharing",
                    stringProviding: stringProviding
                )
            ),
            visitorCode: .init(
                title: Localization2.tr(
                    "Localizable",
                    "call_visualizer.screen_sharing.message",
                    fallback: "Your Screen is Being Shared",
                    stringProviding: stringProviding
                ),
                titleAccessibilityHint: Localization2.tr(
                    "Localizable",
                    "call_visualizer.visitor_code.title.accessibility.hint",
                    fallback: "Shows the five-digit visitor code.",
                    stringProviding: stringProviding
                ),
                closeAccessibilityHint: Localization2.tr(
                    "Localizable",
                    "call_visualizer.visitor_code.close.accessibility.hint",
                    fallback: "Closes the visitor code",
                    stringProviding: stringProviding
                ),
                refreshAccessibilityHint: Localization2.tr(
                    "Localizable",
                    "call_visualizer.visitor_code.refresh.accessibility.hint",
                    fallback: "Generates a new visitor code",
                    stringProviding: stringProviding
                ),
                refreshAccessibilityLabel: Localization2.tr(
                    "Localizable",
                    "call_visualizer.visitor_code.refresh.accessibility.label",
                    fallback: "Refresh Button",
                    stringProviding: stringProviding
                ),
                failed: Localization2.tr(
                    "Localizable",
                    "visitor_code.failed",
                    fallback: "Could not load the visitor code. Please try refreshing.",
                    stringProviding: stringProviding
                )
            )
        ))
    }
}
