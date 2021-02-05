import SalemoveSDK

enum CallKind {
    case audio
    case video
}

enum CallState {
    case none
    case started
    case ended
}

enum CallAudioKind {
    case none
    case remote(AudioStreamable)
    case local(AudioStreamable)
    case twoWay(local: AudioStreamable, remote: AudioStreamable)

    var hasLocalAudio: Bool { return localStream != nil }
    var localStream: AudioStreamable? {
        switch self {
        case .local(let stream):
            return stream
        case .twoWay(local: let stream, _):
            return stream
        default:
            return nil
        }
    }
    var hasRemoteAudio: Bool { return remoteStream != nil }
    var remoteStream: AudioStreamable? {
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
    let audio = ValueProvider<CallAudioKind>(with: .none)
    let duration = ValueProvider<Int>(with: 0)

    init(_ kind: CallKind) {
        self.kind = kind
    }
}
