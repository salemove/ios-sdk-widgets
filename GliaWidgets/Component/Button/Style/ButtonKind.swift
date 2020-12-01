enum ButtonKind {
    case back
    case close
}

extension ButtonKind {
    var properties: ButtonProperties {
        switch self {
        case .back:
            return BackButtonProperties()
        case .close:
            return CloseButtonProperties()
        }
    }
}
