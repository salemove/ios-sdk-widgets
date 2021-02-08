import SalemoveSDK

enum CallKind {
    case audio
    case video

    init?(with offer: MediaUpgradeOffer) {
        switch offer.type {
        case .audio:
            self = .audio
        case .video:
            self = .video
        default:
            return nil
        }
    }
}

enum CallState {
    case none
    case started
    case ended
}

enum CallMediaKind<Streamable> {
    case none
    case remote(Streamable)
    case local(Streamable)
    case twoWay(local: Streamable, remote: Streamable)

    var hasLocalStream: Bool { return localStream != nil }
    var localStream: Streamable? {
        switch self {
        case .local(let stream):
            return stream
        case .twoWay(local: let stream, _):
            return stream
        default:
            return nil
        }
    }
    var hasRemoteStream: Bool { return remoteStream != nil }
    var remoteStream: Streamable? {
        switch self {
        case .remote(let stream):
            return stream
        case .twoWay(_, remote: let stream):
            return stream
        default:
            return nil
        }
    }
}

class Call {
    let id = UUID().uuidString
    let kind: CallKind
    let state = ValueProvider<CallState>(with: .none)
    let audio = ValueProvider<CallMediaKind<AudioStreamable>>(with: .none)
    let video = ValueProvider<CallMediaKind<VideoStreamable>>(with: .none)
    let duration = ValueProvider<Int>(with: 0)

    init(_ kind: CallKind) {
        self.kind = kind
    }
}
