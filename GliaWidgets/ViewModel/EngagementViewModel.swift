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
}
