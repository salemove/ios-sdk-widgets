#if DEBUG
import Foundation

extension SnackBar {
    static let mock: Self = {
        .init { _, _, _, _, _, _, _ in }
    }()
}
#endif
