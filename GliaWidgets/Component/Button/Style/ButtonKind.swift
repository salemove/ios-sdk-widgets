enum ButtonKind {
    case back
    case close
    case alertClose
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
        }
    }
}
