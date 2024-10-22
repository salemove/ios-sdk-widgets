import Foundation

extension EntryWidgetStyle.MediaTypeItemStyle {
    /// The style of a media type item when it is loading.
    public struct LoadingStyle {
        /// Accessibility properties for EntryWidget MediaType Loading.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - accessibility: Accessibility properties for EntryWidget MediaType Loading.
        public init(
            accessibility: Accessibility = .unsupported
        ) {
            self.accessibility = accessibility
        }
    }
}
