import Foundation

class EngagementViewModel: CommonEngagementModel {
    typealias ActionCallback = (Action) -> Void
    typealias DelegateCallback = (DelegateEvent) -> Void

    var engagementAction: ActionCallback?
    var engagementDelegate: DelegateCallback?
    let interactor: Interactor
    let environment: Environment
    // Need to keep strong reference of `activeEngagement`,
    // to be able to fetch survey after ending engagement
    var activeEngagement: CoreSdkClient.Engagement?
    private(set) var hasViewAppeared: Bool
    private(set) var isViewActive = ObservableValue<Bool>(with: false)
    /// A flag indicating where enqueue will replace existing one.
    /// Used when 'Leave Current Conversation?' dialog is closed with 'Leave' button.
    let replaceExistingEnqueueing: Bool

    init(
        interactor: Interactor,
        replaceExistingEnqueueing: Bool,
        environment: Environment
    ) {
        self.interactor = interactor
        self.environment = environment
        self.hasViewAppeared = false
        self.replaceExistingEnqueueing = replaceExistingEnqueueing
        self.interactor.addObserver(self) { [weak self] event in
            self?.interactorEvent(event)
        }
    }

    deinit {
        interactor.removeObserver(self)
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
            switch interactor.state {
            case .none, .ended:
                closeTapped()
            case .engaged where interactor.currentEngagement?.isTransferredSecureConversation == true:
                closeTapped()
            case .engaged, .enqueueing, .enqueued:
                engagementDelegate?(.back)
            }
        case .closeTapped:
            closeTapped()
        }
    }

    func viewDidAppear() {}

    func viewWillAppear() {}

    func start() {}

    func enqueue(engagementKind: EngagementKind, replaceExisting: Bool) async {
        do {
            try await interactor.enqueueForEngagement(
                engagementKind: engagementKind,
                replaceExisting: replaceExisting
            )
        } catch let error as CoreSdkClient.GliaCoreError {
            self.handleError(error)
        } catch {
            return
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
                        Task { [weak self] in
                            guard let self else { return }
                            await self.enqueue(
                                engagementKind: engagementKind,
                                replaceExisting: replaceExistingEnqueueing
                            )
                        }
                    } else {
                        self.showLiveObservationConfirmation(in: engagementKind)
                    }
                case let .failure(error):
                    self.engagementAction?(.showAlert(.error(
                        error: error,
                        dismissed: endSession
                    )))
                }
            }
        default:
            break
        }
    }

    @MainActor
    func endSession() async {
        try? await interactor.endSession()
        self.engagementDelegate?(.finished)
    }

    func setViewAppeared() {
        hasViewAppeared = true
    }
}

// MARK: - Private
private extension EngagementViewModel {
    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            engagementAction?(.showAlert(.leaveQueue(confirmed: { [weak self] in
                Task { [weak self] in
                    await self?.endSession()
                }
            })))
        case .engaged where interactor.currentEngagement?.isTransferredSecureConversation == false:
            engagementAction?(.showAlert(.endEngagement(confirmed: { [weak self] in
                Task { [weak self] in
                    await self?.endSession()
                }
            })))
        default:
            Task { [weak self] in
                await self?.endSession()
            }
        }
    }

    private func handleError(_ error: CoreSdkClient.SalemoveError) {
        engagementAction?(.showAlert(.error(
            error: error.error,
            dismissed: {
                Task { [weak self] in
                    await self?.endSession()
                }
            }
        )))
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
                Task { [weak self] in
                    guard let self else { return }
                    await self.enqueue(
                        engagementKind: engagementKind,
                        replaceExisting: self.replaceExistingEnqueueing
                    )
                }
            },
            declined: { [weak self] in
                Task { [weak self] in
                    await self?.endSession()
                }
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
    }

    enum Action {
        case showEndButton
        case showCloseButton
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
