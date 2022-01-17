class MediaUpgradeToOneWayVideoAlertProperties: MediaUpgradeProperties {
    var items: [AlertItem] {
        [
            .illustration(configuration.titleImage ?? Asset.upgradeVideo.image),
            .title(configuration.title.withOperatorName(operatorName)),
            .actions([declineAction, acceptAction]),
            configuration.showsPoweredBy ? .poweredByGlia : nil
        ].compactMap({ $0 })
    }

    var showsCloseButton: Bool {
        false
    }
    
    var declineAction: AlertAction
    var acceptAction: AlertAction

    private let configuration: SingleMediaUpgradeAlertConfiguration
    private let operatorName: String

    init(
        configuration: SingleMediaUpgradeAlertConfiguration,
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
