extension ChatFileDownloadStyle {
    /// Accessibility properties for ChatFileDownloadStyle.
    public struct StateAccessibility {
        /// Accessibility format string for `FileDownload.State.none`
        public var noneState: String
        /// Accessibility format string for `FileDownload.State.downloading`
        public var downloadingState: String
        /// Accessibility format string for `FileDownload.State.downloaded`
        public var downloadedState: String
        /// Accessibility format string for `FileDownload.State.error`
        public var errorState: String

        ///
        /// - Parameters:
        ///   - noneState: Accessibility format string for `FileDownload.State.none`
        ///   - downloadingState: Accessibility format string for `FileDownload.State.downloading`
        ///   - downloadedState: Accessibility format string for `FileDownload.State.downloaded`
        ///   - errorState: Accessibility format string for `FileDownload.State.error`
        public init(
            noneState: String,
            downloadingState: String,
            downloadedState: String,
            errorState: String
        ) {
            self.noneState = noneState
            self.downloadingState = downloadingState
            self.downloadedState = downloadedState
            self.errorState = errorState
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            noneState: "",
            downloadingState: "",
            downloadedState: "",
            errorState: ""
        )
    }
}
