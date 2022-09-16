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
