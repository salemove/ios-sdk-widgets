import Foundation

extension EngagementStyle {
    public static func == (lhs: EngagementStyle, rhs: EngagementStyle) -> Bool {
        return lhs.header == rhs.header &&
               lhs.connect == rhs.connect &&
               lhs.backgroundColor == rhs.backgroundColor &&
               lhs.preferredStatusBarStyle == rhs.preferredStatusBarStyle
    }
}
