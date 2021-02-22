import SalemoveSDK

class EngagementViewModel {
    enum Event {
        case viewDidAppear
        case viewDidDisappear
        case backTapped
        case closeTapped
    }

    enum Action {
        case confirm(ConfirmationAlertConfiguration,
                     confirmed: (() -> Void)?)
        case showAlert(MessageAlertConfiguration,
                       dismissed: (() -> Void)?)
        case showSettingsAlert(SettingsAlertConfiguration,
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
    let alertConfiguration: AlertConfiguration

    private(set) var isViewActive = ValueProvider<Bool>(with: false)
    private static var alertPresenters = Set<EngagementViewModel>()

    init(interactor: Interactor, alertConfiguration: AlertConfiguration) {
        self.interactor = interactor
        self.alertConfiguration = alertConfiguration
        interactor.addObserver(self, handler: interactorEvent)
    }

    deinit {
        interactor.removeObserver(self)
    }

    func event(_ event: Event) {
        switch event {
        case .viewDidAppear:
            isViewActive.value = true
            viewDidAppear()
        case .viewDidDisappear:
            isViewActive.value = false
        case .backTapped:
            engagementDelegate?(.back)
        case .closeTapped:
            closeTapped()
        }
    }

    func viewDidAppear() {}

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

    func update(for state: InteractorState) {}

    func stateChanged(_ state: InteractorState) {
        update(for: state)

        switch state {
        case .engaged(let engagedOperator):
            engagementDelegate?(.engaged(operatorImageUrl: engagedOperator?.picture?.url))
        case .ended:
            if EngagementViewModel.alertPresenters.isEmpty {
                engagementDelegate?(.finished)
            }
        default:
            break
        }
    }

    func showAlert(with conf: MessageAlertConfiguration, dismissed: (() -> Void)? = nil) {
        let onDismissed = {
            EngagementViewModel.alertPresenters.remove(self)
            dismissed?()

            switch self.interactor.state {
            case .ended:
                self.endSession()
            default:
                break
            }
        }
        EngagementViewModel.alertPresenters.insert(self)
        engagementAction?(.showAlert(conf, dismissed: { onDismissed() }))
    }

    func showAlert(for error: Error) {
        showAlert(with: alertConfiguration.unexpectedError)
    }

    func showAlert(for error: SalemoveError) {
        showAlert(with: alertConfiguration.unexpectedError)
    }

    func showSettingsAlert(with conf: SettingsAlertConfiguration, cancelled: (() -> Void)? = nil) {
        engagementAction?(.showSettingsAlert(conf, cancelled: cancelled))
    }

    func alertConfiguration(with error: SalemoveError) -> MessageAlertConfiguration {
        return MessageAlertConfiguration(with: error,
                                templateConf: self.alertConfiguration.apiError)
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
            engagementAction?(.confirm(alertConfiguration.leaveQueue,
                                       confirmed: { self.endSession() }))
        case .engaged:
            engagementAction?(.confirm(alertConfiguration.endEngagement,
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
                self.showAlert(with: self.alertConfiguration.operatorsUnavailable,
                               dismissed: { self.endSession() })
            default:
                self.showAlert(with: self.alertConfiguration.unexpectedError,
                               dismissed: { self.endSession() })
            }
        default:
            self.showAlert(with: self.alertConfiguration.unexpectedError,
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
