class EngagementEndedAlertProperties: AlertProperties {
    var items: [AlertItem] {
        [
            .title(configuration.title ?? L10n.Alert.OperatorEndedEngagement.title),
            .message(configuration.message ?? L10n.Alert.OperatorEndedEngagement.message),
            .actions([action])
        ]
    }

    var showsCloseButton: Bool {
        false
    }

    var action: AlertAction

    private let configuration: SingleActionAlertConfiguration

    init(configuration: SingleActionAlertConfiguration) {
        self.configuration = configuration

        self.action = AlertAction(
            title: configuration.buttonTitle ?? L10n.Alert.Action.ok,
            style: .regular
        )
    }
}
