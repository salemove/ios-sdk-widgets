enum ButtonKind {
    case close
    case alertClose
}

extension ButtonKind {
    var properties: ButtonProperties {
        switch self {
        case .close:
            return CloseButtonProperties()
        case .alertClose:
            return AlertCloseButtonProperties()
        }
    }
}
