class APIErrorAlertProperties: AlertProperties {
    var items: [AlertItem] {
        [
            .title(configuration.title ?? L10n.Alert.ApiError.title),
            .message(configuration.message ?? L10n.Alert.ApiError.message)
        ]
    }

    let showsCloseButton: Bool = true

    private let configuration: MessageAlertConfiguration

    init(configuration: MessageAlertConfiguration) {
        self.configuration = configuration
    }
}
