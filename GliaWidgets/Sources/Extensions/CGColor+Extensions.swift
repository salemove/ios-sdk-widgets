import UIKit
import SwiftUI

extension CGColor {
    static var clear: CGColor {
        UIColor.clear.cgColor
    }

    func swiftUIColor() -> SwiftUI.Color {
        return SwiftUI.Color(self)
    }
}
