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
                return "Live Chat"
            case .audio:
                return "Audio"
            case .video:
                return "Video"
            case .secureMessaging:
                return "SecureMessaging"
            }
        }

        var subheadline: String {
            switch self {
            case .chat:
                return "For the texter in all of us"
            case .audio:
                return "Speak through your device"
            case .video:
                return "Face-to-face, just like in person"
            case .secureMessaging:
                return "Start a conversation, we'll get back to you"
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
