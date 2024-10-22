import UIKit

extension EntryWidgetStyle.MediaTypeItemStyle.LoadingStyle {
    /// Accessibility properties for EntryWidget MediaType Loading.
    public struct Accessibility: Equatable {
        /// Accessibility label.
        public var label: String

        /// - Parameters:
        ///   - label: Accessibility label.
        public init(
            label: String
        ) {
            self.label = label
        }
    }
}

extension EntryWidgetStyle.MediaTypeItemStyle.LoadingStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        label: ""
    )
}
