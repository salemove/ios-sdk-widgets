import UIKit

#if DEBUG
extension MessageRenderer {
    static let mock = Self { _ in nil }
}
#endif
