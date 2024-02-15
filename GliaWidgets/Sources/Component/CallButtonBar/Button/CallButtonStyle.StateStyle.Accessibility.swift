import Foundation

extension CallButtonStyle.StateStyle {
    /// Accessibility properties for CallButtonStyle.StateStyle.
    public struct Accessibility: Equatable {
        /// Accessibility label.
        public var label: String

        /// - Parameters:
        ///   - label: Accessibility label.
        ///
        public init(label: String) {
            self.label = label
        }
    }
}

extension CallButtonStyle.StateStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(label: "")
}
