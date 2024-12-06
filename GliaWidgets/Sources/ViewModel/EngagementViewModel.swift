import Foundation

class EngagementViewModel: CommonEngagementModel {
    typealias ActionCallback = (Action) -> Void
    typealias DelegateCallback = (DelegateEvent) -> Void

    var engagementAction: ActionCallback?
    var engagementDelegate: DelegateCallback?
    let interactor: Interactor
    let environment: Environment
    let screenShareHandler: ScreenShareHandler
    // Need to keep strong reference of `activeEngagement`,
    // to be able to fetch survey after ending engagement
    var activeEngagement: CoreSdkClient.Engagement?
    private(set) var hasViewAppeared: Bool
    private(set) var isViewActive = ObservableValue<Bool>(with: false)

    init(
        interactor: Interactor,
        screenShareHandler: ScreenShareHandler,
        environment: Environment
    ) {
        self.interactor = interactor
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
            engagementAction?(.showAlert(.endScreenShare(confirmed: endScreenSharing)))
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
                    self.engagementAction?(.showAlert(.operatorEndedEngagement(action: { [weak self] in
                        self?.endSession()
                    })))
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
                self.engagementAction?(.showAlert(.operatorEndedEngagement(action: { [weak self] in
                    self?.endSession()
                    self?.engagementDelegate?(
                          .engaged(
                              operatorImageUrl: nil
                           )
                    )
                })))
            })
        case let .enqueueing(mediaType):
            environment.fetchSiteConfigurations { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(site):
                    if site.mobileConfirmDialogEnabled == false || self.interactor.skipLiveObservationConfirmations {
                        self.enqueue(mediaType: mediaType)
                    } else {
                        self.showLiveObservationConfirmation(in: mediaType)
                    }
                case let .failure(error):
                    self.engagementAction?(.showAlert(.error(
                        error: error,
                        dismissed: conditionallyEndSession
                    )))
                }
            }
        default:
            break
        }
    }

    func updateScreenSharingState(to state: CoreSdkClient.VisitorScreenSharingState) {
        if state.status == .sharing {
            environment.log.prefixed(Self.self).info("Screen sharing started")
        }
        screenShareHandler.updateState(state)
    }

    func endScreenSharing() {
        screenShareHandler.stop(nil)
        engagementAction?(.showEndButton)
        environment.log.prefixed(Self.self).info("Screen sharing ended")
    }

    func endSession() {
        interactor.endSession { [weak self] in
            self?.engagementDelegate?(.finished)
        } failure: { [weak self] _ in
            self?.engagementDelegate?(.finished)
        }
        self.screenShareHandler.stop(nil)
    }

    func conditionallyEndSession() {
        switch self.interactor.state {
        case .ended:
            self.endSession()
        default:
            break
        }
    }

    func setViewAppeared() {
        hasViewAppeared = true
    }
}

// MARK: - Private
private extension EngagementViewModel {
    private func offerScreenShare(answer: @escaping CoreSdkClient.AnswerBlock) {
        environment.alertManager.present(
            in: .global,
            as: .screenSharing(
                operators: interactor.engagedOperator?.firstName ?? "",
                answer: answer
            )
        )
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            engagementAction?(.showAlert(.leaveQueue(confirmed: { [weak self] in
                self?.endSession()
            })))
        case .engaged:
            engagementAction?(.showAlert(.endEngagement(confirmed: { [weak self] in
                self?.endSession()
            })))
        default:
            endSession()
        }
    }

    private func handleError(_ error: CoreSdkClient.SalemoveError) {
        engagementAction?(.showAlert(.error(
            error: error.error,
            dismissed: endSession
        )))
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
        engagementAction?(.showLiveObservationConfirmation(
            link: { [weak self] link in
                self?.engagementDelegate?(.openLink(link))
            },
            accepted: { [weak self] in
                self?.enqueue(mediaType: mediaType)
            },
            declined: { [weak self] in
                self?.endSession()
            }
        ))
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
        case showEndButton
        case showEndScreenShareButton
        case showLiveObservationConfirmation(
            link: (WebViewController.Link) -> Void,
            accepted: () -> Void,
            declined: () -> Void
        )
        case showAlert(AlertInputType)
    }

    enum DelegateEvent {
        case back
        case openLink(WebViewController.Link)
        case engaged(operatorImageUrl: String?)
        case finished
    }
}
