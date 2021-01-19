import SalemoveSDK

class CallViewModel: EngagementViewModel, ViewModel {
    enum Event {
        case viewDidLoad
        case backTapped
        case closeTapped
    }

    enum Action {
        case queueWaiting
        case queueConnecting
        case queueConnected(name: String?, imageUrl: String?)
        case showEndButton
        case confirm(ConfirmationAlertConf,
                     confirmed: (() -> Void)?)
        case showAlert(MessageAlertConf,
                       dismissed: (() -> Void)?)
    }

    enum DelegateEvent {
        case back
        case operatorImage(url: String?)
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    override init(interactor: Interactor, alertConf: AlertConf) {
        super.init(interactor: interactor, alertConf: alertConf)
    }

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
        case .backTapped:
            delegate?(.back)
        case .closeTapped:
            closeTapped()
        }
    }

    private func start() {
        //enqueue()
    }

    private func enqueue() {
        interactor.enqueueForEngagement {

        } failure: { error in
            self.handleError(error)
        }
    }

    private func end() {
        interactor.endSession {
            self.delegate?(.finished)
        } failure: { _ in
            self.delegate?(.finished)
        }
    }

    private func closeTapped() {
        switch interactor.state {
        case .enqueueing, .enqueued:
            action?(.confirm(alertConf.leaveQueue,
                             confirmed: { self.end() }))
        case .engaged:
            action?(.confirm(alertConf.endEngagement,
                             confirmed: { self.end() }))
        default:
            end()
        }
    }

    private func handleError(_ error: SalemoveError) {
        switch error.error {
        case let queueError as QueueError:
            switch queueError {
            case .queueClosed, .queueFull:
                self.showAlert(with: self.alertConf.operatorsUnavailable,
                               dismissed: { self.end() })
            default:
                self.showAlert(with: self.alertConf.unexpectedError,
                               dismissed: { self.end() })
            }
        default:
            self.showAlert(with: self.alertConf.unexpectedError,
                           dismissed: { self.end() })
        }
    }

    private func showAlert(with conf: MessageAlertConf, dismissed: (() -> Void)?) {
        let dismissHandler = {
            self.alertState = .none
            dismissed?()

            switch self.interactor.state {
            case .inactive:
                self.end()
            default:
                break
            }
        }

        alertState = .presenting

        action?(.showAlert(conf, dismissed: { dismissHandler() }))
    }

    override func interactorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(let state):
            switch state {
            case .inactive:
                if alertState == .none {
                    delegate?(.finished)
                }
            case .enqueueing:
                action?(.queueWaiting)
            case .enqueued:
                break
            case .engaged(let engagedOperator):
                let name = engagedOperator?.firstName
                let pictureUrl = engagedOperator?.picture?.url
                action?(.queueConnected(name: name, imageUrl: pictureUrl))
                action?(.showEndButton)
                delegate?(.operatorImage(url: engagedOperator?.picture?.url))
            }
        case .upgradeOffer(let offer, answer: let answer):
            break
        case .error(let error):
            self.handleError(error)
        default:
            break
        }
    }
}
