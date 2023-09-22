import SwiftUI

/// Accessibility identifier view modifier for resolving between
/// deprecated and new method to specify accessibility identifier.
struct MigrationAccessibilityIdentifierModifier: ViewModifier {
    let identifier: String

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.accessibilityIdentifier(identifier)
        } else {
            content.accessibility(identifier: identifier)
        }
    }
}

/// Modifier for specifying accessibility identifier for avoiding deprecation warning.
extension View {
    func migrationAccessibilityIdentifier(_ identifier: String) -> some View {
        self.modifier(MigrationAccessibilityIdentifierModifier(identifier: identifier))
    }
}
