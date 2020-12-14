import SalemoveSDK

class EngagementViewModel {
    let interactor: Interactor
    let alertStrings: AlertStrings

    init(interactor: Interactor, alertStrings: AlertStrings) {
        self.interactor = interactor
        self.alertStrings = alertStrings

        interactor.addObserver(self, handler: interactorEvent)
    }

    deinit {
        interactor.removeObserver(self)
    }

    func interactorEvent(_ event: InteractorEvent) {}

    func alertStrings(with error: SalemoveError) -> AlertMessageStrings {
        return AlertMessageStrings(with: error,
                                   templateStrings: self.alertStrings.apiError)
    }
}
