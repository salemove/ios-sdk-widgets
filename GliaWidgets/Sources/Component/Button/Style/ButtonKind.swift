enum ButtonKind {
    case close
    case alertClose
    case visitorCodeClose
}

extension ButtonKind {
    var properties: ButtonProperties {
        switch self {
        case .close:
            return CloseButtonProperties()
        case .alertClose:
            return AlertCloseButtonProperties()
        case .visitorCodeClose:
            return VisitorCodeCloseButtonProperties()
        }
    }
}
