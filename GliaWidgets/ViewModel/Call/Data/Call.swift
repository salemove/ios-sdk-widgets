import SalemoveSDK

enum CallKind {
    case audio
    case video
}

enum CallState {
    case none
    case started
    case progressed(duration: Int)
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
}

class Call {
    let id = UUID().uuidString
    let kind: CallKind
    let state = Provider<CallState>(with: .none)
    let audio = Provider<CallAudioKind>(with: .none)

    init(_ kind: CallKind) {
        self.kind = kind
    }
}
