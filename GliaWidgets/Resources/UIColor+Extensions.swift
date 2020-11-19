import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((hex >> 16) & 0xff),
                  green: CGFloat((hex >> 8) & 0xff),
                  blue: CGFloat(hex & 0xff),
                  alpha: alpha)
       }
}
