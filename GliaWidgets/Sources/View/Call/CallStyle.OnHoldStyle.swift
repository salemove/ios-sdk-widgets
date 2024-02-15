import UIKit

extension CallStyle {
    /// On Hold Style is applied when the visitor has been put on hold.
    public struct OnHoldStyle: Equatable {
        /// The text shown in the top section of the call view when visitor is put on hold.
        public var onHoldText: String

        /// The text shown in the bottom section of the call view when visitor is put on hold.
        public var descriptionText: String

        /// The text shown in the local video stream view when visitor is put on hold.
        public var localVideoStreamLabelText: String

        /// The text font for the label in the local video stream view when visitor is put on hold.
        public var localVideoStreamLabelFont: UIFont

        /// The text color for the label in the local video stream view when visitor is put on hold.
        public var localVideoStreamLabelColor: UIColor

        /// - Parameters:
        ///   - topText: The text shown in the top section of the call view when visitor is put on hold.
        ///   - bottomText: The text shown in the bottom section of the call view when visitor is put on hold.
        ///   - localVideoStreamText: The text shown in the local video stream view when visitor is put on hold.
        ///   - localVideoStreamLabelFont: The text font for the label in the local video stream view when
        ///     visitor is put on hold.
        ///   - localVideoStreamLabelColor: The text color for the label in the local video stream view
        ///     when visitor is put on hold.
        ///
        public init(
            onHoldText: String,
            descriptionText: String,
            localVideoStreamLabelText: String,
            localVideoStreamLabelFont: UIFont,
            localVideoStreamLabelColor: UIColor
        ) {
            self.onHoldText = onHoldText
            self.descriptionText = descriptionText
            self.localVideoStreamLabelText = localVideoStreamLabelText
            self.localVideoStreamLabelFont = localVideoStreamLabelFont
            self.localVideoStreamLabelColor = localVideoStreamLabelColor
        }
    }
}
