import SalemoveSDK

class EngagementViewModel {
    let interactor: Interactor
    let alertConf: AlertConf

    init(interactor: Interactor, alertConf: AlertConf) {
        self.interactor = interactor
        self.alertConf = alertConf

        interactor.addObserver(self, handler: interactorEvent)
    }

    deinit {
        interactor.removeObserver(self)
    }

    func interactorEvent(_ event: InteractorEvent) {}

    func alertConf(with error: SalemoveError) -> MessageAlertConf {
        return MessageAlertConf(with: error,
                                templateConf: self.alertConf.apiError)
    }
}
