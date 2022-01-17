struct AlertAction {
    enum Style {
        case regular
        case destructive
    }

    let title: String
    let style: Style

    var handler: (() -> Void)?
}
