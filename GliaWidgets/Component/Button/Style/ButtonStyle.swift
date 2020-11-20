enum ButtonStyle {
    case back
    case close
}

extension ButtonStyle {
    var properties: ButtonProperties {
        switch self {
        case .back:
            return BackButtonProperties()
        case .close:
            return CloseButtonProperties()
        }
    }
}
