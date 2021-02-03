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
