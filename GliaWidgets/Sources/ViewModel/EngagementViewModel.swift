import Foundation

class EngagementViewModel: CommonEngagementModel {
    typealias ActionCallback = (Action) -> Void
    typealias DelegateCallback = (DelegateEvent) -> Void
    static let alertSingleActionAccessibilityIdentifier = "alert_close_engagementEnded"
    var engagementAction: ActionCallback?
    var engagementDelegate: DelegateCallback?
    let interactor: Interactor
    let alertConfiguration: AlertConfiguration
    let environment: Environment
    let screenShareHandler: ScreenShareHandler
    // Need to keep strong reference of `activeEngagement`,
    // to be able to fetch survey after ending engagement
    var activeEngagement: CoreSdkClient.Engagement?
    private(set) var hasViewAppeared: Bool
    private(set) var isViewActive = ObservableValue<Bool>(with: false)

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
        self.hasViewAppeared = false
        self.interactor.addObserver(self) { [weak self] event in
            self?.interactorEvent(event)
        }
        screenShareHandler.status().addObserver(self) { [weak self] status, _ in
            self?.onScreenSharingStatusChange(status)
        }
    }

    deinit {
        interactor.removeObserver(self)
        screenShareHandler.status().removeObserver(self)
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
                    accessibilityIdentifier: "alert_confirmation_endScreenSharing",
                    confirmed: { self.endScreenSharing() }
                )
            )
        }
    }

    func viewDidAppear() {}

    func viewWillAppear() {
        if interactor.state == .ended(.byOperator) {
            interactor.currentEngagement?.getSurvey { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let survey) where survey != nil:
                    return
                default:
                    self.engagementAction?(
                        .showSingleActionAlert(
                            self.alertConfiguration.operatorEndedEngagement,
                            accessibilityIdentifier: Self.alertSingleActionAccessibilityIdentifier,
                            actionTapped: { [weak self] in
                                self?.endSession()
                            }
                        )
                    )
                }
            }
        }
    }

    func start() {}

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
            engagementDelegate?(
                .engaged(
                    operatorImageUrl: nil
                )
            )
            engagementDelegate?(.finished)

        case .ended(let reason) where reason == .byOperator:
            interactor.currentEngagement?.getSurvey(completion: { [weak self] result in

                guard let self = self else { return }
                guard case .success(let survey) = result, survey == nil else {
                    self.endSession()
                    return
                }

                self.engagementAction?(
                    .showSingleActionAlert(
                        self.alertConfiguration.operatorEndedEngagement,
                        accessibilityIdentifier: Self.alertSingleActionAccessibilityIdentifier,
                        actionTapped: { [weak self] in
                            self?.endSession()
                            self?.engagementDelegate?(
                                  .engaged(
                                      operatorImageUrl: nil
                                   )
                            )
                        }
                    )
                )
            })
        case let .enqueueing(mediaType):
            environment.fetchSiteConfigurations { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(site):
                    if site.mobileConfirmDialog == false {
                        self.enqueue(mediaType: mediaType)
                    } else {
                        self.showLiveObservationConfirmation(in: mediaType)
                    }
                case .failure:
                    self.showAlert(with: self.alertConfiguration.unexpectedError, dismissed: nil)
                }
            }
        default:
            break
        }
    }

    func showAlert(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String? = nil,
        dismissed: (() -> Void)? = nil
    ) {
        let onDismissed = {
            dismissed?()

            switch self.interactor.state {
            case .ended:
                self.endSession()
            default:
                break
            }
        }
        engagementAction?(
            .showAlert(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: { onDismissed() }
            )
        )
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
        screenShareHandler.updateState(state)
    }

    func endScreenSharing() {
        screenShareHandler.stop(nil)
        engagementAction?(.showEndButton)
    }

    func endSession() {
        interactor.endSession { [weak self] in
            self?.engagementDelegate?(.finished)
        } failure: { [weak self] _ in
            self?.engagementDelegate?(.finished)
        }
        self.screenShareHandler.stop(nil)
    }

    func setViewAppeared() {
        hasViewAppeared = true
    }
}

// MARK: - Private
private extension EngagementViewModel {
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

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            engagementAction?(
                .confirm(
                    alertConfiguration.leaveQueue,
                    accessibilityIdentifier: "alert_confirmation_leaveQueue",
                    confirmed: { [weak self] in
                        self?.endSession()
                    }
                )
            )
        case .engaged:
            engagementAction?(
                .confirm(
                    alertConfiguration.endEngagement,
                    accessibilityIdentifier: "alert_confirmation_endEngagement",
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
            case .queueClosed:
                showAlert(
                    with: alertConfiguration.operatorsUnavailable,
                    accessibilityIdentifier: "alert_queue_closed",
                    dismissed: { self.endSession() }
                )
            case .queueFull:
                showAlert(
                    with: alertConfiguration.operatorsUnavailable,
                    accessibilityIdentifier: "alert_queue_full",
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

// MARK: Live Observation

extension EngagementViewModel {
    private func showLiveObservationConfirmation(in mediaType: CoreSdkClient.MediaType) {
        let liveObservationAlertConfig = createLiveObservationAlertConfig(with: mediaType)
        engagementAction?(.showLiveObservationConfirmation(liveObservationAlertConfig))
    }

    private func createLiveObservationAlertConfig(
        with mediaType: CoreSdkClient.MediaType
    ) -> LiveObservation.Confirmation {
        .init(
            conf: self.alertConfiguration.liveObservationConfirmation,
            link: { [weak self] link in
                self?.engagementDelegate?(.openLink(link))
            },
            accepted: { [weak self] in
                self?.enqueue(mediaType: mediaType)
            },
            declined: { [weak self] in
                self?.endSession()
            }
        )
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
            accessibilityIdentifier: String,
            confirmed: (() -> Void)?
        )
        case showSingleActionAlert(
            SingleActionAlertConfiguration,
            accessibilityIdentifier: String,
            actionTapped: (() -> Void)?
        )
        case showAlert(
            MessageAlertConfiguration,
            accessibilityIdentifier: String?,
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
        case showLiveObservationConfirmation(LiveObservation.Confirmation)
    }

    enum DelegateEvent {
        case back
        case openLink(WebViewController.Link)
        case engaged(operatorImageUrl: String?)
        case finished
    }
}
