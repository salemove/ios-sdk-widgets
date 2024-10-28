import Foundation

extension EntryWidgetStyle.MediaTypeItemStyle {
    /// The style of a media type item when it is loading.
    public struct LoadingStyle {
        /// The color of the placeholders during the loading state.
        public var loadingTintColor: ColorType

        /// Accessibility properties for EntryWidget MediaType Loading.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - loadingTintColor: The color of the placeholders during the loading state.
        ///   - accessibility: Accessibility properties for EntryWidget MediaType Loading.
        public init(
            loadingTintColor: ColorType,
            accessibility: Accessibility = .unsupported
        ) {
            self.loadingTintColor = loadingTintColor
            self.accessibility = accessibility
        }
    }
}
