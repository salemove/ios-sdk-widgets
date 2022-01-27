import SalemoveSDK

class EngagementViewModel {
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
    }

    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case finished
        case alert(Alert)
    }

    var engagementAction: ((Action) -> Void)?
    var engagementDelegate: ((DelegateEvent) -> Void)?

    let interactor: Interactor

    private let screenShareHandler: ScreenShareHandler
    private var disposables: [Disposable] = []

    init(
        interactor: Interactor,
        screenShareHandler: ScreenShareHandler
    ) {
        self.interactor = interactor
        self.screenShareHandler = screenShareHandler

        interactor.event
            .observe({ [weak self] in
                self?.interactorEvent($0)
            })
            .add(to: &disposables)

        screenShareHandler.status
            .observe({ [weak self] in
                self?.onScreenSharingStatusChange($0)
            })
            .add(to: &disposables)
    }

    deinit {
        screenShareHandler.cleanUp()
    }

    func event(_ event: Event) {
        switch event {
        case .viewWillAppear:
            viewWillAppear()
        case .viewDidAppear:
            viewDidAppear()
        case .viewDidDisappear:
            break
        case .backTapped:
            engagementDelegate?(.back)
        case .closeTapped:
            closeTapped()
        case .endScreenSharingTapped:
            engagementDelegate?(
                .alert(
                    .endScreenShareAlert(confirmed: { [weak self] in
                        self?.endScreenSharing()
                    })
                )
            )
        }
    }

    func viewDidAppear() {}

    func viewWillAppear() {
        if interactor.state == .ended(.byOperator) {
            engagementDelegate?(
                .alert(.operatorEndedEngagement)
            )
        }
    }

    func start() {
        update(for: interactor.state)
    }

    func enqueue(mediaType: MediaType) {
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

        case .upgradeOffer(let offer, let answer):
            offerMediaUpgrade(offer, answer: answer)

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
        case .ended(let reason):
            engagementDelegate?(
                .engaged(
                    operatorImageUrl: nil
                )
            )

            switch reason {
            case .byVisitor:
                engagementDelegate?(.finished)

            case .byOperator:
                engagementDelegate?(
                    .alert(.operatorEndedEngagement)
                )

            case .byError:
                break
            }
        default:
            break
        }
    }

    func updateScreenSharingState(to state: VisitorScreenSharingState) {
        screenShareHandler.updateState(to: state)
    }

    func endScreenSharing() {
        screenShareHandler.stop()
        engagementAction?(.showEndButton)
    }

    private func offerScreenShare(
        answer: @escaping AnswerBlock
    ) {
        let operatorName = interactor.engagedOperator?.firstName

        engagementDelegate?(
            .alert(
                .startScreenShareAlert(
                    answer: answer,
                    operatorName: operatorName ?? L10n.operator
                )
            )
        )
    }

    private func offerMediaUpgrade(
        _ offer: MediaUpgradeOffer,
        answer: @escaping AnswerWithSuccessBlock
    ) {
        let operatorName = interactor.engagedOperator?.firstName

        engagementDelegate?(
            .alert(
                .mediaUpgradeAlert(
                    offer: offer,
                    answer: answer,
                    operatorName: operatorName ?? L10n.operator
                )
            )
        )
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
            engagementDelegate?(
                .alert(
                    .leaveQueueAlert(confirmed: { [weak self] in
                        self?.endSession()
                    })
                )
            )

        case .engaged:
            engagementDelegate?(
                .alert(
                    .endEngagementAlert(confirmed: { [weak self] in
                        self?.endSession()
                    })
                )
            )

        default:
            endSession()
        }
    }

    func handleError(_ error: SalemoveError) {
        switch error.error {
        case
            let queueError as QueueError where queueError == .queueClosed,
            let queueError as QueueError where queueError == .queueFull:
            engagementDelegate?(
                .alert(.operatorsUnavailable)
            )
        default:
            engagementDelegate?(
                .alert(.unexpectedError)
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
