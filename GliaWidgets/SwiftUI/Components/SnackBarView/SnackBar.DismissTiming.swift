import Foundation

extension SnackBar {
    /// Controls when and how the SnackBar is dismissed.
    enum DismissTiming {
        /// The SnackBar automatically dismisses after a specified TimeInterval.
        case auto(timeInterval: TimeInterval)

        /// The SnackBar remains until manually dismissed using the provided closure.
        case manual(dismiss: (@escaping () -> Void) -> Void)

        static let `default`: Self = .auto(timeInterval: 3)
    }
}
