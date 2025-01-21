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

    func viewWillAppear() {}

    func start() {}

    func enqueue(engagementKind: EngagementKind) {
        interactor.enqueueForEngagement(
            engagementKind: engagementKind,
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

        case .ended:
            // We no longer perform any checks in `EngagementViewModel`, regarding
            // survey, because these checks were performed several times at once
            // (because of inheritance from `EngagementViewModel`):
            // in `CallViewModel` and `ChatViewModel` when both are instantiated.
            // That resulted in conflicting view presentation attempts.
            // So this logic was moved to `ChatViewModel`, since it is always a part
            // of any engagement, where it will be performed only once.
            break

        case let .enqueueing(engagementKind):
            environment.fetchSiteConfigurations { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(site):
                    if site.mobileConfirmDialogEnabled == false || self.interactor.skipLiveObservationConfirmations {
                        self.enqueue(engagementKind: engagementKind)
                    } else {
                        self.showLiveObservationConfirmation(in: engagementKind)
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
        interactor.endSession { [weak self] _ in
            self?.engagementDelegate?(.finished)
        }
        screenShareHandler.stop(nil)
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
    private func showLiveObservationConfirmation(in engagementKind: EngagementKind) {
        engagementAction?(.showLiveObservationConfirmation(
            link: { [weak self] link in
                self?.engagementDelegate?(.openLink(link))
            },
            accepted: { [weak self] in
                self?.enqueue(engagementKind: engagementKind)
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
