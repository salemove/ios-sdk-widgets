import Foundation
import UIKit

extension UIFont {
    static func convertToFont(
        uiFont: UIFont?,
        textStyle: UIFont.TextStyle
    ) -> UIFont? {
        FontScaling.theme.uiFont(
            with: textStyle,
            font: uiFont
        )
    }

    static func font(
        weight: UIFont.Weight,
        size: CGFloat
    ) -> UIFont {
        return .systemFont(ofSize: size, weight: weight)
    }

    static func italicFont(
        weight: UIFont.Weight = .regular,
        size: CGFloat
    ) -> UIFont {
        let font = font(weight: weight, size: size)
        return font.withTraits(.traitItalic, ofSize: size) ?? font
    }
}

extension UIFont.Weight {
    init(fontStyle: RemoteConfiguration.FontStyle) {
        switch fontStyle {
        case .regular, .italic:
            self = .regular
        case .bold:
            self = .bold
        case .thin:
            self = .thin
        }
    }
}

extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits..., ofSize size: CGFloat) -> UIFont? {
        let symbolicTraits = UIFontDescriptor.SymbolicTraits(traits)
        guard
            let descriptor = fontDescriptor.withSymbolicTraits(symbolicTraits)
        else { return nil }
        return UIFont(descriptor: descriptor, size: size)
    }
}

extension UIFont {
    /// Returns a font instance that is scaled appropriately based on the user's current content size category preferences
    /// for the specified `UIFont.TextStyle`. It resolves the internal `FontScaling.Style` and `FontScaling.Description`
    /// to retrieve the original font's weight and size, then scales it according to the current content size category.
    static func scaledFont(forTextStyle: UIFont.TextStyle) -> UIFont? {
        var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: forTextStyle)
        guard let style = FontScaling.Style(forTextStyle),
              let description = FontScaling.theme.descriptions[style] else {
            return nil
        }
        descriptor = descriptor.addingAttributes(
            [
                UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: description.weight]
            ]
        )
        // Create a font copy with original size to scale it with current preferred content size category
        let fontCopy = UIFont(descriptor: descriptor, size: description.size)

        return UIFontMetrics(forTextStyle: forTextStyle).scaledFont(for: fontCopy)
    }
}
