import SwiftUI

extension EntryWidget {
    struct MediaTypeItem: Equatable, Hashable {
        let type: EngagementType
        var badgeCount: Int
        let headline: String
        let subheadline: String
        let hintline: String
        let image: Image

        init(
            type: EntryWidget.EngagementType,
            badgeCount: Int,
            headline: String,
            subheadline: String,
            hintline: String,
            image: Image
        ) {
            self.type = type
            self.badgeCount = badgeCount
            self.headline = headline
            self.subheadline = subheadline
            self.hintline = hintline
            self.image = image
        }

        init(type: EngagementType, badgeCount: Int = 0) {
            switch type {
            case .video:
                self.init(
                    type: type,
                    badgeCount: badgeCount,
                    headline: Localization.EntryWidget.Video.Button.label,
                    subheadline: Localization.EntryWidget.Video.Button.description,
                    hintline: Localization.EntryWidget.Video.Button.Accessibility.hint,
                    image: Asset.callVideoActive.image
                )
            case .audio:
                self.init(
                    type: .audio,
                    badgeCount: badgeCount,
                    headline: Localization.EntryWidget.Audio.Button.label,
                    subheadline: Localization.EntryWidget.Audio.Button.description,
                    hintline: Localization.EntryWidget.Audio.Button.Accessibility.hint,
                    image: Asset.callMuteInactive.image
                )
            case .chat:
                self.init(
                    type: type,
                    badgeCount: badgeCount,
                    headline: Localization.EntryWidget.LiveChat.Button.label,
                    subheadline: Localization.EntryWidget.LiveChat.Button.description,
                    hintline: Localization.EntryWidget.LiveChat.Button.Accessibility.hint,
                    image: Asset.callChat.image
                )
            case .secureMessaging:
                self.init(
                    type: type,
                    badgeCount: badgeCount,
                    headline: Localization.EntryWidget.SecureMessaging.Button.label,
                    subheadline: Localization.EntryWidget.SecureMessaging.Button.description,
                    hintline: Localization.EntryWidget.SecureMessaging.Button.Accessibility.hint,
                    image: Asset.mcEnvelope.image
                )
            case .callVisualizer:
                self.init(
                    type: type,
                    badgeCount: 0,
                    headline: "Call Visualizer",
                    subheadline: "",
                    hintline: "",
                    image: Asset.callVisualizer.image
                )
            }
        }
    }

    enum EngagementType: Int, CustomStringConvertible {
        case video
        case audio
        case chat
        case secureMessaging
        case callVisualizer

        var description: String {
            switch self {
            case .video: return "video"
            case .audio: return "audio"
            case .chat: return "chat"
            case .secureMessaging: return "secureMessaging"
            case .callVisualizer: return "callVisualizer"
            }
        }
    }
}

extension EntryWidget.EngagementType {
    init?(mediaType: MediaType) {
        switch mediaType {
        case .audio:
            self = .audio
        case .video:
            self = .video
        case .text:
            self = .chat
        case .messaging:
            self = .secureMessaging
        case .phone, .unknown:
            return nil
        @unknown default:
            debugPrint("💥 Unknown type MediaType received in: \(Self.self)")
            return nil
        }
    }
}
