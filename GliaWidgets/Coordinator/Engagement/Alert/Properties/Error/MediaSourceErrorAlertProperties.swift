class MediaSourceErrorAlertProperties: AlertProperties {
    var items: [AlertItem] {
        [
            .title(configuration.title ?? L10n.Alert.MediaSourceNotAvailable.title),
            .message(configuration.message ?? L10n.Alert.MediaSourceNotAvailable.message)
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
