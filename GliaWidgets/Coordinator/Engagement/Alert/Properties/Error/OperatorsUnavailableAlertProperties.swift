class OperatorsUnavailableAlertProperties: AlertProperties {
    var items: [AlertItem] {
        [
            .title(configuration.title ?? L10n.Alert.OperatorsUnavailable.title),
            .message(configuration.message ?? L10n.Alert.OperatorsUnavailable.message)
        ]
    }

    var showsCloseButton: Bool {
        true
    }

    private let configuration: MessageAlertConfiguration

    init(configuration: MessageAlertConfiguration) {
        self.configuration = configuration
    }
}
