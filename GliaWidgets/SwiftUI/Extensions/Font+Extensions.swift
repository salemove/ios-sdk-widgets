import SwiftUI
import UIKit

extension Font {
    static func convert(_ uiFont: UIFont, textStyle: UIFont.TextStyle = .body) -> Font {
        let swiftUIStyle = Font.TextStyle(textStyle)

        // System fonts (SF) => use system text style so it scales, then apply weight
        if uiFont.fontName.hasPrefix(".") || uiFont.familyName.hasPrefix(".") {
            return .system(swiftUIStyle, design: .default).weight(uiFont.swiftUIWeight)
        }

        // Custom fonts (Roboto, etc.) => must use relativeTo so it scales
        return .custom(uiFont.fontName, size: uiFont.pointSize, relativeTo: swiftUIStyle)
    }
}

extension Font.TextStyle {
    init(_ style: UIFont.TextStyle) {
        switch style {
        case .largeTitle: self = .largeTitle
        case .title1:     self = .title
        case .title2:     self = .title2
        case .title3:     self = .title3
        case .headline:   self = .headline
        case .subheadline: self = .subheadline
        case .callout:    self = .callout
        case .footnote:   self = .footnote
        case .caption1:   self = .caption
        case .caption2:   self = .caption2
        default:          self = .body
        }
    }
}

private extension UIFont {
    var swiftUIWeight: Font.Weight {
        let w = ((fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any])?[.weight] as? CGFloat) ?? 0
        switch w {
        case ..<(-0.6): return .ultraLight
        case ..<(-0.4): return .thin
        case ..<(-0.2): return .light
        case ..<(0.1):  return .regular
        case ..<(0.3):  return .medium
        case ..<(0.4):  return .semibold
        case ..<(0.6):  return .bold
        case ..<(0.8):  return .heavy
        default:         return .black
        }
    }
}
