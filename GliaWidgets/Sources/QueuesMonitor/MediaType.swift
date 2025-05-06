import Foundation
import GliaCoreSDK

public enum MediaType: String, Decodable {
    /// Audio stream
    case audio

    /// Video stream
    case video

    /// Text messages
    case text

    /// Asynchronous messages
    case messaging

    /// Phone call
    case phone

    /// Current SDK version unsupported media type
    case unknown

    public init(mediaType: GliaCoreSDK.MediaType) {
        switch mediaType {
        case .audio:
            self = .audio
        case .video:
            self = .video
        case .text:
            self = .text
        case .messaging:
            self = .messaging
        case .phone:
            self = .phone
        case .unknown:
            self = .unknown
        @unknown default:
            self = .unknown
        }
    }
}
