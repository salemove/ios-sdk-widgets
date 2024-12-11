import UIKit

extension EntryWidgetStyle.MediaTypeItemStyle {
    /// Accessibility properties for EntryWidget MediaType.
    public struct Accessibility: Equatable {
        /// The accessibility hint for chat media type.
        public var chatHint: String

        /// The accessibility hint for audio media type.
        public var audioHint: String

        /// The accessibility hint for video media type.
        public var videoHint: String

        /// The accessibility hint for secure messaging media type.
        public var secureMessagingHint: String

        /// The accessibility hint for call visualizer.
        public var callVisualizerHint: String

        /// - Parameters:
        ///   - chatHint: The accessibility hint for chat media type.
        ///   - audioHint: The accessibility hint for audio media type.
        ///   - videoHint: The accessibility hint for video media type.
        ///   - secureMessagingHint: The accessibility hint for secure messaging media type.
        ///   - callVisualizer: The accessibility hint for call visualizer.
        ///
        public init(
            chatHint: String,
            audioHint: String,
            videoHint: String,
            secureMessagingHint: String,
            callVisualizerHint: String
        ) {
            self.chatHint = chatHint
            self.audioHint = audioHint
            self.videoHint = videoHint
            self.secureMessagingHint = secureMessagingHint
            self.callVisualizerHint = callVisualizerHint
        }

        func hint(for item: EntryWidget.MediaTypeItem) -> String {
            switch item.type {
            case .chat:
                return chatHint
            case .audio:
                return audioHint
            case .video:
                return videoHint
            case .secureMessaging:
                return secureMessagingHint
            case .callVisualizer:
                return callVisualizerHint
            }
        }
    }
}

extension EntryWidgetStyle.MediaTypeItemStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        chatHint: "",
        audioHint: "",
        videoHint: "",
        secureMessagingHint: "",
        callVisualizerHint: ""
    )
}
