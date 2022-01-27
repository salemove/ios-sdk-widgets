class StartScreenShareAlertProperties: AlertProperties {
    var items: [AlertItem] {
        [
            .illustration(configuration.titleImage ?? Asset.startScreenShare.image),
            .title(configuration.title.withOperatorName(operatorName)),
            .message(configuration.message.withOperatorName(operatorName)),
            .actions([declineAction, acceptAction])
        ]
    }

    let showsCloseButton: Bool = false

    var declineAction: AlertAction
    var acceptAction: AlertAction

    private let configuration: ScreenShareOfferAlertConfiguration
    private let operatorName: String

    init(
        configuration: ScreenShareOfferAlertConfiguration,
        operatorName: String
    ) {
        self.configuration = configuration
        self.operatorName = operatorName

        self.declineAction = AlertAction(
            title: configuration.decline,
            style: .regular
        )

        self.acceptAction = AlertAction(
            title: configuration.accept,
            style: .destructive
        )
    }
}
