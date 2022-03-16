import Foundation

// swiftlint:disable type_body_length
class EngagementViewModel {

    var engagementAction: ((Action) -> Void)?
    var engagementDelegate: ((DelegateEvent) -> Void)?

    let interactor: Interactor
    let alertConfiguration: AlertConfiguration
    let environment: Environment
    let screenShareHandler: ScreenShareHandler
    var activeEngagement: CoreSdkClient.Engagement?

    private(set) var isViewActive = ObservableValue<Bool>(with: false)
    private static var alertPresenters = Set<EngagementViewModel>()

    init(
        interactor: Interactor,
        alertConfiguration: AlertConfiguration,
        screenShareHandler: ScreenShareHandler,
        environment: Environment
    ) {
        self.interactor = interactor
        self.alertConfiguration = alertConfiguration
        self.screenShareHandler = screenShareHandler
        self.environment = environment
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
        case .viewWillAppear:
            viewWillAppear()
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

    func viewWillAppear() {
        if interactor.state == .ended(.byOperator) {
            EngagementViewModel.alertPresenters.insert(self)
            engagementAction?(
                .showSingleActionAlert(
                    alertConfiguration.operatorEndedEngagement,
                    actionTapped: { [weak self] in
                        self?.endSession()
                    }
                )
            )
        }
    }

    func start() {
        update(for: interactor.state)
    }

    func enqueue(mediaType: CoreSdkClient.MediaType) {
        interactor.enqueueForEngagement(
            mediaType: mediaType,
            success: {},
            failure: { [weak self] error in
                self?.handleError(error)
            }
        )
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

    // swiftlint:disable function_body_length
    func stateChanged(_ state: InteractorState) {
        update(for: state)

        switch state {
        case .engaged(let engagedOperator):
            engagementDelegate?(
                .engaged(
                    operatorImageUrl: engagedOperator?.picture?.url
                )
            )
            activeEngagement = environment.getCurrentEngagement()

        case .ended(let reason) where reason == .byVisitor:

            let noSurveyOp = { [weak self] in
                self?.engagementDelegate?(
                    .engaged(
                        operatorImageUrl: nil
                    )
                )
                self?.engagementDelegate?(.finished(nil, nil))
            }

            if let activeEngagement = activeEngagement {
                activeEngagement.getSurvey { [weak self] result in
                    guard
                        case .success(let survey) = result,
                        let survey = survey
                    else {
                        noSurveyOp()
                        return
                    }

                    self?.engagementDelegate?(
                        .engaged(
                            operatorImageUrl: nil
                        )
                    )
                    self?.engagementDelegate?(.finished(activeEngagement.id, survey))
                }
            } else {
                noSurveyOp()
            }

        case .ended(let reason) where reason == .byOperator:

            let noSurveyOp = { [weak self] (showAlert: Bool) -> Void in
                guard let self = self else { return }
                self.engagementDelegate?(
                    .engaged(
                        operatorImageUrl: nil
                    )
                )
                if showAlert { EngagementViewModel.alertPresenters.insert(self)
                    self.engagementAction?(
                        .showSingleActionAlert(
                            self.alertConfiguration.operatorEndedEngagement,
                            actionTapped: { [weak self] in
                                self?.endSession()
                            }
                        )
                    )
                }
            }

            if let activeEngagement = activeEngagement {
                activeEngagement.getSurvey { [weak self] result in
                    guard
                        case .success(let survey) = result,
                        let survey = survey
                    else {
                        noSurveyOp(true)
                        return
                    }

                    self?.interactor.endSession {
                        self?.engagementDelegate?(.finished(activeEngagement.id, survey))
                    } failure: { _ in
                        self?.engagementDelegate?(.finished(activeEngagement.id, survey))
                    }
                    self?.screenShareHandler.cleanUp()
                }
            } else {
                noSurveyOp(true)
            }

        default:
            break
        }
    }
    // swiftlint:enable function_body_length

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

    func showAlert(for error: CoreSdkClient.SalemoveError) {
        showAlert(with: alertConfiguration.unexpectedError)
    }

    func showSettingsAlert(
        with conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)? = nil
    ) {
        engagementAction?(.showSettingsAlert(conf, cancelled: cancelled))
    }

    func alertConfiguration(
        with error: CoreSdkClient.SalemoveError
    ) -> MessageAlertConfiguration {
        return MessageAlertConfiguration(
            with: error,
            templateConf: alertConfiguration.apiError
        )
    }

    func updateScreenSharingState(to state: CoreSdkClient.VisitorScreenSharingState) {
        screenShareHandler.updateState(to: state)
    }

    func endScreenSharing() {
        screenShareHandler.stop()
        engagementAction?(.showEndButton)
    }

    private func offerScreenShare(answer: @escaping CoreSdkClient.AnswerBlock) {
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
        let op = { [weak self] (engagementId: String?, survey: CoreSdkClient.Survey?) -> Void in
            self?.interactor.endSession {
                self?.engagementDelegate?(.finished(engagementId, survey))
            } failure: { _ in
                self?.engagementDelegate?(.finished(engagementId, survey))
            }
            self?.screenShareHandler.cleanUp()
        }

        if let activeEngagement = activeEngagement {
            activeEngagement.getSurvey { result in
                guard
                    case .success(let survey) = result,
                    let survey = survey
                else {
                    op(nil, nil)
                    return
                }

                op(activeEngagement.id, survey)

            }
        } else {
            op(nil, nil)
        }
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            engagementAction?(
                .confirm(
                    alertConfiguration.leaveQueue,
                    confirmed: { [weak self] in
                        self?.endSession()
                    }
                )
            )
        case .engaged:
            engagementAction?(
                .confirm(
                    alertConfiguration.endEngagement,
                    confirmed: { [weak self] in
                        self?.endSession()
                    }
                )
            )
        default:
            endSession()
        }
    }

    private func handleError(_ error: CoreSdkClient.SalemoveError) {
        switch error.error {
        case let queueError as CoreSdkClient.QueueError:
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
            engagementAction?(.showEndButton)
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

extension EngagementViewModel {

    enum Event {
        case viewWillAppear
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
        case showSingleActionAlert(
            SingleActionAlertConfiguration,
            actionTapped: (() -> Void)?
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
        case finished(String?, CoreSdkClient.Survey?)
    }
}
// swiftlint:enable type_body_length
