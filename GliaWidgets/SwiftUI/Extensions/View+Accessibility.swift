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

/// Accessibility label view modifier for resolving between
/// deprecated and new method to specify accessibility label.
struct MigrationAccessibilityLabelModifier: ViewModifier {
    let label: String

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.accessibilityLabel(label)
        } else {
            content.accessibility(label: .init(label))
        }
    }
}

/// Accessibility hint view modifier for resolving between
/// deprecated and new method to specify accessibility hint.
struct MigrationAccessibilityHintModifier: ViewModifier {
    let hint: String

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.accessibilityHint(hint)
        } else {
            content.accessibility(hint: .init(hint))
        }
    }
}

/// Accessibility addTraits view modifier for resolving between
/// deprecated and new method to add accessibility traits.
struct MigrationAccessibilityAddTraitModifier: ViewModifier {
    let trait: AccessibilityTraits

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.accessibilityAddTraits(trait)
        } else {
            content.accessibility(addTraits: trait)
        }
    }
}

/// Accessibility removeTraits view modifier for resolving between
/// deprecated and new method to accessibility traits.
struct MigrationAccessibilityDropTraitModifier: ViewModifier {
    let trait: AccessibilityTraits

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.accessibilityRemoveTraits(trait)
        } else {
            content.accessibility(removeTraits: trait)
        }
    }
}

/// Accessibility hidden view modifier for resolving between
/// deprecated and new method to hidden or show accessibility.
struct MigrationAccessibilityHiddenModifier: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.accessibilityHidden(isHidden)
        } else {
            content.accessibility(hidden: isHidden)
        }
    }
}

/// Modifiers for specifying accessibility for avoiding deprecation warning.
extension View {
    func migrationAccessibilityIdentifier(_ identifier: String) -> some View {
        self.modifier(MigrationAccessibilityIdentifierModifier(identifier: identifier))
    }

    func migrationAccessibilityLabel(_ label: String) -> some View {
        self.modifier(MigrationAccessibilityLabelModifier(label: label))
    }

    func migrationAccessibilityHint(_ hint: String) -> some View {
        self.modifier(MigrationAccessibilityHintModifier(hint: hint))
    }

    func migrationAccessibilityAddTrait(_ trait: AccessibilityTraits) -> some View {
        self.modifier(MigrationAccessibilityAddTraitModifier(trait: trait))
    }

    func migrationAccessibilityRemoveTrait(_ trait: AccessibilityTraits) -> some View {
        self.modifier(MigrationAccessibilityDropTraitModifier(trait: trait))
    }

    func migrationAccessibilityHidden(_ isHidden: Bool) -> some View {
        self.modifier(MigrationAccessibilityHiddenModifier(isHidden: isHidden))
    }
}
