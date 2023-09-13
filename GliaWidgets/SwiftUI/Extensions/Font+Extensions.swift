import SwiftUI

extension Font {
    static func convert(_ uiFont: UIFont) -> Font {
        return .custom(uiFont.familyName + uiFont.fontName, size: uiFont.pointSize)
    }
}
