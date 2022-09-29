import Foundation
import UIKit

extension UIFont {
    static func convertToFont(font: RemoteConfiguration.Font?) -> UIFont? {
        if let fontSize = font?.size, let fontStyle = font?.style {
            switch fontStyle {
            case .bold:
                return UIFont.boldSystemFont(ofSize: fontSize)
            case .italic:
                return UIFont.italicSystemFont(ofSize: fontSize)
            case .regular:
                return UIFont.systemFont(ofSize: fontSize)
            case .thin:
                return UIFont.systemFont(ofSize: fontSize, weight: .thin)
            }
        } else {
            return nil
        }
    }
}

extension UIFont {
    func weight(orDefault defaultValue: CGFloat) -> CGFloat {
        guard let face = fontDescriptor.object(forKey: .face) as? String else { return defaultValue }
        switch face.lowercased() {
        case "bold":    return 0.5
        case "thin":    return 0.05
        default:        return 0.2
        }
    }
}
