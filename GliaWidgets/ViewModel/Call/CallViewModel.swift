import SalemoveSDK

class CallViewModel: EngagementViewModel, ViewModel {
    enum Event {
        case viewDidLoad
    }

    enum Action {
        case queueWaiting
        case queueConnecting
        case queueConnected(name: String?, imageUrl: String?)
    }

    enum DelegateEvent {}

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    override init(interactor: Interactor, alertConf: AlertConf) {
        super.init(interactor: interactor, alertConf: alertConf)
    }

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
        }
    }

    private func start() {
        //enqueue()
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

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
        default:
            break
        }
    }
}
