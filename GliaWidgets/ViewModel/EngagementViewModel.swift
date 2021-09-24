import SalemoveSDK

class EngagementViewModel {
    enum Event {
        case viewDidAppear
        case viewDidDisappear
        case backTapped
        case closeTapped
        case endScreenSharingTapped
    }

    enum Action {
        case confirm(
            ConfirmationAlertConfiguration,
            confirmed: (() -> Void)?
        )
        case showAlert(
            MessageAlertConfiguration,
            dismissed: (() -> Void)?
        )
        case showSettingsAlert(
            SettingsAlertConfiguration,
            cancelled: (() -> Void)?
        )
        case offerScreenShare(
            ScreenShareOfferAlertConfiguration,
            accepted: () -> Void,
            declined: () -> Void
        )
        case showEndButton
        case showEndScreenShareButton
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

    private let screenShareHandler: ScreenShareHandler
    private(set) var isViewActive = ObservableValue<Bool>(with: false)
    private static var alertPresenters = Set<EngagementViewModel>()

    init(
        interactor: Interactor,
        alertConfiguration: AlertConfiguration,
        screenShareHandler: ScreenShareHandler
    ) {
        self.interactor = interactor
        self.alertConfiguration = alertConfiguration
        self.screenShareHandler = screenShareHandler
        interactor.addObserver(self, handler: interactorEvent)
        screenShareHandler.status.addObserver(self) { [weak self] status, _ in
            self?.onScreenSharingStatusChange(status)
        }
    }

    deinit {
        interactor.removeObserver(self)
        screenShareHandler.status.removeObserver(self)
        screenShareHandler.cleanUp()
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
        case .endScreenSharingTapped:
            engagementAction?(
                .confirm(
                    alertConfiguration.endScreenShare,
                    confirmed: { self.endScreenSharing() }
                )
            )
        }
    }

    func viewDidAppear() {}

    func start() {
        update(for: interactor.state)
    }

    func enqueue() {
        interactor.enqueueForEngagement {} failure: { error in
            self.handleError(error)
        }
    }

    func interactorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(let state):
            stateChanged(state)
        case .error(let error):
            handleError(error)
        case .screenShareOffer(let answer):
            offerScreenShare(answer: answer)
        case .screenSharingStateChanged(let state):
            updateScreenSharingState(to: state)
        default:
            break
        }
    }

    func update(for state: InteractorState) {}

    func stateChanged(_ state: InteractorState) {
        update(for: state)

        switch state {
        case .engaged(let engagedOperator):
            engagementDelegate?(
                .engaged(
                    operatorImageUrl: engagedOperator?.picture?.url
                )
            )
        case .ended:
            if EngagementViewModel.alertPresenters.isEmpty {
                engagementDelegate?(.finished)
            }
        default:
            break
        }
    }

    func showAlert(
        with conf: MessageAlertConfiguration,
        dismissed: (() -> Void)? = nil
    ) {
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

    func showSettingsAlert(
        with conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)? = nil
    ) {
        engagementAction?(.showSettingsAlert(conf, cancelled: cancelled))
    }

    func alertConfiguration(
        with error: SalemoveError
    ) -> MessageAlertConfiguration {
        return MessageAlertConfiguration(
            with: error,
            templateConf: alertConfiguration.apiError
        )
    }

    func updateScreenSharingState(to state: VisitorScreenSharingState) {
        screenShareHandler.updateState(to: state)
    }

    func endScreenSharing() {
        screenShareHandler.stop()
        engagementAction?(.showEndButton)
    }

    private func offerScreenShare(answer: @escaping AnswerBlock) {
        guard isViewActive.value else { return }
        let operatorName = interactor.engagedOperator?.firstName
        let configuration = alertConfiguration.screenShareOffer
        engagementAction?(.offerScreenShare(
            configuration.withOperatorName(operatorName),
            accepted: { answer(true) },
            declined: { answer(false) }
        ))
    }

    private func endSession() {
        interactor.endSession {
            self.engagementDelegate?(.finished)
        } failure: { _ in
            self.engagementDelegate?(.finished)
        }
        screenShareHandler.cleanUp()
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            engagementAction?(
                .confirm(
                    alertConfiguration.leaveQueue,
                    confirmed: { self.endSession() }
                )
            )
        case .engaged:
            engagementAction?(
                .confirm(
                    alertConfiguration.endEngagement,
                    confirmed: { self.endSession() }
                )
            )
        default:
            endSession()
        }
    }

    private func handleError(_ error: SalemoveError) {
        switch error.error {
        case let queueError as QueueError:
            switch queueError {
            case .queueClosed, .queueFull:
                showAlert(
                    with: alertConfiguration.operatorsUnavailable,
                    dismissed: { self.endSession() }
                )
            default:
                showAlert(
                    with: alertConfiguration.unexpectedError,
                    dismissed: { self.endSession() }
                )
            }
        default:
            showAlert(
                with: alertConfiguration.unexpectedError,
                dismissed: { self.endSession() }
            )
        }
    }

    private func onScreenSharingStatusChange(_ status: ScreenSharingStatus) {
        switch status {
        case .started:
            engagementAction?(.showEndScreenShareButton)
        case .stopped:
            return
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
