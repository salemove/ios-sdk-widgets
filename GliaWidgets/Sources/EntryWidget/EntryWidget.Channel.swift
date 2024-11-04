import GliaCoreSDK
import SwiftUI

extension EntryWidget {
    enum MediaTypeItem: Int {
        case video
        case audio
        case chat
        case secureMessaging

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

extension EntryWidget.MediaTypeItem {
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
