import GliaCoreSDK
import SwiftUI

extension EntryWidget {
    enum Channel {
        case chat
        case audio
        case video
        case secureMessaging

        var headline: String {
            switch self {
            case .chat:
                return Localization.EntryWidget.LiveChat.Button.label
            case .audio:
                return Localization.EntryWidget.Audio.Button.label
            case .video:
                return Localization.EntryWidget.Video.Button.label
            case .secureMessaging:
                return Localization.EntryWidget.SecureMessaging.Button.label
            }
        }

        var subheadline: String {
            switch self {
            case .chat:
                return Localization.EntryWidget.LiveChat.Button.description
            case .audio:
                return Localization.EntryWidget.Audio.Button.description
            case .video:
                return Localization.EntryWidget.Video.Button.description
            case .secureMessaging:
                return Localization.EntryWidget.SecureMessaging.Button.description
            }
        }

        var image: UIImage {
            switch self {
            case .chat:
                return Asset.callChat.image
            case .audio:
                return Asset.callMuteInactive.image
            case .video:
                return Asset.callVideoActive.image
            case .secureMessaging:
                return Asset.mcEnvelope.image
            }
        }
    }
}

extension EntryWidget.Channel {
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
