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

class Call {
    let id = UUID().uuidString
    let kind: CallKind
    let state = Provider<CallState>(with: .none)

    init(_ kind: CallKind) {
        self.kind = kind
    }
}
