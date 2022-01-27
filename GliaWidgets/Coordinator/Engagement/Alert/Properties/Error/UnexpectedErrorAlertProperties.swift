class UnexpectedErrorAlertProperties: AlertProperties {
    var items: [AlertItem] {
        [
            .title(configuration.title ?? L10n.Alert.Unexpected.title),
            .message(configuration.message ?? L10n.Alert.Unexpected.message)
        ]
    }

    let showsCloseButton: Bool = true

    private let configuration: MessageAlertConfiguration

    init(configuration: MessageAlertConfiguration) {
        self.configuration = configuration
    }
}
