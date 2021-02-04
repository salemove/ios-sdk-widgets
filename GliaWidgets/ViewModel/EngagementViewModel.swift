import SalemoveSDK

class EngagementViewModel {
    enum Event {
        case backTapped
        case closeTapped
    }

    enum Action {
        case showEndButton
        case confirm(ConfirmationAlertConf,
                     confirmed: (() -> Void)?)
        case showAlert(MessageAlertConf,
                       dismissed: (() -> Void)?)
        case showSettingsAlert(SettingsAlertConf,
                               cancelled: (() -> Void)?)
    }

    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case finished
    }

    var engagementAction: ((Action) -> Void)?
    var engagementDelegate: ((DelegateEvent) -> Void)?

    let interactor: Interactor
    let alertConf: AlertConf

    private static var alertPresenters = Set<EngagementViewModel>()

    init(interactor: Interactor, alertConf: AlertConf) {
        self.interactor = interactor
        self.alertConf = alertConf
        interactor.addObserver(self, handler: interactorEvent)
    }

    deinit {
        interactor.removeObserver(self)
    }

    func event(_ event: Event) {
        switch event {
        case .backTapped:
            engagementDelegate?(.back)
        case .closeTapped:
            closeTapped()
        }
    }

    func start() {
        update(for: interactor.state)
    }

    func enqueue() {
        interactor.enqueueForEngagement {

        } failure: { error in
            self.handleError(error)
        }
    }

    func interactorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(let state):
            stateChanged(state)
        case .error(let error):
            handleError(error)
        default:
            break
        }
    }

    func update(for state: InteractorState) {
        switch interactor.state {
        case .engaged:
            engagementAction?(.showEndButton)
        default:
            break
        }
    }

    func stateChanged(_ state: InteractorState) {
        update(for: state)

        switch state {
        case .inactive:
            if EngagementViewModel.alertPresenters.isEmpty {
                engagementDelegate?(.finished)
            }
        case .engaged(let engagedOperator):
            engagementDelegate?(.engaged(operatorImageUrl: engagedOperator?.picture?.url))
        default:
            break
        }
    }

    func showAlert(with conf: MessageAlertConf, dismissed: (() -> Void)? = nil) {
        let dismissHandler = {
            EngagementViewModel.alertPresenters.remove(self)
            dismissed?()

            switch self.interactor.state {
            case .inactive:
                self.endSession()
            default:
                break
            }
        }
        EngagementViewModel.alertPresenters.insert(self)
        engagementAction?(.showAlert(conf, dismissed: { dismissHandler() }))
    }

    func showAlert(for error: Error) {
        showAlert(with: alertConf.unexpectedError)
    }

    func showAlert(for error: SalemoveError) {
        showAlert(with: alertConf.unexpectedError)
    }

    func showSettingsAlert(with conf: SettingsAlertConf, cancelled: (() -> Void)? = nil) {
        engagementAction?(.showSettingsAlert(conf, cancelled: cancelled))
    }

    func alertConf(with error: SalemoveError) -> MessageAlertConf {
        return MessageAlertConf(with: error,
                                templateConf: self.alertConf.apiError)
    }

    private func endSession() {
        interactor.endSession {
            self.engagementDelegate?(.finished)
        } failure: { _ in
            self.engagementDelegate?(.finished)
        }
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            engagementAction?(.confirm(alertConf.leaveQueue,
                                       confirmed: { self.endSession() }))
        case .engaged:
            engagementAction?(.confirm(alertConf.endEngagement,
                                       confirmed: { self.endSession() }))
        default:
            endSession()
        }
    }

    private func handleError(_ error: SalemoveError) {
        switch error.error {
        case let queueError as QueueError:
            switch queueError {
            case .queueClosed, .queueFull:
                self.showAlert(with: self.alertConf.operatorsUnavailable,
                               dismissed: { self.endSession() })
            default:
                self.showAlert(with: self.alertConf.unexpectedError,
                               dismissed: { self.endSession() })
            }
        default:
            self.showAlert(with: self.alertConf.unexpectedError,
                           dismissed: { self.endSession() })
        }
    }
}

extension EngagementViewModel: Hashable {
    static func == (lhs: EngagementViewModel, rhs: EngagementViewModel) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
