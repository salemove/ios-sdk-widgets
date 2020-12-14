import SalemoveSDK

class ChatViewModel: EngagementViewModel, ViewModel {
    enum Event {
        case viewDidLoad
        case backTapped
        case closeTapped
    }

    enum Action {
        case queueWaiting
        case queueConnecting(name: String)
        case queueConnected(name: String)
        case showEndButton
        case appendRows(Int)
        case refreshItems
        case confirm(AlertConfirmationStrings,
                     confirmed: (() -> Void)?)
        case showAlert(AlertMessageStrings,
                       dismissed: (() -> Void)?)
    }

    enum DelegateEvent {
        case back
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private var items = [ChatItem]()

    override init(interactor: Interactor, alertStrings: AlertStrings) {
        super.init(interactor: interactor, alertStrings: alertStrings)
    }

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            enqueue()
        case .backTapped:
            delegate?(.back)
        case .closeTapped:
            closeTapped()
        }
    }

    private func enqueue() {
        interactor.enqueueForEngagement {

        } failure: { error in
            switch error.error {
            case is QueueError:
                break
            default:
                self.action?(.showAlert(self.alertStrings(with: error),
                                        dismissed: { self.end() }))
            }
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
            action?(.confirm(alertStrings.leaveQueue,
                             confirmed: { self.end() }))
        case .engaged:
            action?(.confirm(alertStrings.endEngagement,
                             confirmed: { self.end() }))
        default:
            end()
        }
    }

    private func appendItem(_ item: ChatItem) {
        appendItems([item])
    }

    private func appendItems(_ newItems: [ChatItem]) {
        items.append(contentsOf: newItems)
        action?(.appendRows(newItems.count))
    }

    override func interactorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(let state):
            switch state {
            case .inactive:
                delegate?(.finished)
            case .enqueueing:
                action?(.queueWaiting)
            case .enqueued(_):
                action?(.queueConnecting(name: "Blah"))
            case .engaged:
                action?(.queueConnected(name: "Blah"))
                action?(.showEndButton)
            }
        case .error(let error):
            break
        }
    }
}

extension ChatViewModel {
    var numberOfItems: Int { return items.count }

    func item(for row: Int) -> ChatItem {
        return items[row]
    }
}
