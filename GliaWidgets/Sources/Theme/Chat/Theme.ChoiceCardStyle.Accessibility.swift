import Foundation

extension Theme.ChoiceCardStyle {
    /// Accessibility properties for `ChoiceCardStyle`.
    public struct Accessibility: Equatable {
        /// Accessibility label for image.
        public var imageLabel: String

        /// - Parameters:
        ///   - imageLabel: Accessibility label for image.
        ///
        public init(imageLabel: String) {
            self.imageLabel = imageLabel
        }
    }
}

extension Theme.ChoiceCardStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(imageLabel: "")
}
