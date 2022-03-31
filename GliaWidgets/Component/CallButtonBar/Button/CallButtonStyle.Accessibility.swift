extension CallButtonStyle {
    /// Accessibility properties for CallButtonStyle.
    public struct Accessibility: Equatable {
        /// Accessibility value for single item in badge.
        public var singleItemBadgeValue: String
        /// Accessibility value for multiple items in badge.
        public var multipleItemsBadgeValue: String
        /// Concatenated button title and badge value for accessibility label.
        /// The order of concatenation is based on provided localization via `{buttonTitle}, {badgeValue}` pattern.
        public var titleAndBadgeValue: String

        ///
        /// - Parameters:
        ///   - singleItemBadgeValue: Accessibility value for single item in badge.
        ///   - multipleItemsBadgeValue: Accessibility value for multiple items in badge.
        ///   - titleAndBadgeValue: Concatenated button title and badge value for accessibility label. The order of concatenation is based on provided localization via `{buttonTitle}, {badgeValue}` pattern.
        init(
            singleItemBadgeValue: String,
            multipleItemsBadgeValue: String,
            titleAndBadgeValue: String
        ) {
            self.singleItemBadgeValue = singleItemBadgeValue
            self.multipleItemsBadgeValue = multipleItemsBadgeValue
            self.titleAndBadgeValue = titleAndBadgeValue
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            singleItemBadgeValue: "",
            multipleItemsBadgeValue: "",
            titleAndBadgeValue: ""
        )
    }
}
