import Foundation
import UIKit

extension UIFont {
    static func convertToFont(font: RemoteConfiguration.Font?, textStyle: UIFont.TextStyle) -> UIFont? {
        let fontScaling = FontScaling.theme
        if let fontSize = font?.size, let fontStyle = font?.style {
            let weight = UIFont.Weight(fontStyle: fontStyle)
            let font = fontStyle == .italic ? Self.italicFont(weight:size:) : Self.font(weight:size:)
            return fontScaling.uiFont(
                with: textStyle,
                font: font(weight, fontSize)
            )
        } else {
            return nil
        }
    }

    private static func font(
        weight: UIFont.Weight,
        size: CGFloat
    ) -> UIFont {
        return .systemFont(ofSize: size, weight: weight)
    }

    private static func italicFont(
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
