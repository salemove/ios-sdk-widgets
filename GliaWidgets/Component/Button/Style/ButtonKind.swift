enum ButtonKind {
    case back
    case close
    case alertClose
    case chatPickMedia
    case chatSend
}

extension ButtonKind {
    var properties: ButtonProperties {
        switch self {
        case .back:
            return BackButtonProperties()
        case .close:
            return CloseButtonProperties()
        case .alertClose:
            return AlertCloseButtonProperties()
        case .chatPickMedia:
            return ChatPickMediaButtonProperties()
        case .chatSend:
            return ChatSendButtonProperties()
        }
    }
}
