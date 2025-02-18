import UIKit

class CallCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case openLink(WebViewController.Link)
        case engaged(operatorImageUrl: String?)
        case visitorOnHoldUpdated(isOnHold: Bool)
        case chat
        case minimize
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter
    private let call: Call
    private let unreadMessages: ObservableValue<Int>
    private let screenShareHandler: ScreenShareHandler
    private let startAction: CallViewModel.StartAction
    private let environment: Environment

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        navigationPresenter: NavigationPresenter,
        call: Call,
        unreadMessages: ObservableValue<Int>,
        screenShareHandler: ScreenShareHandler,
        startAction: CallViewModel.StartAction,
        environment: Environment
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.call = call
        self.unreadMessages = unreadMessages
        self.screenShareHandler = screenShareHandler
        self.startAction = startAction
        self.environment = environment
    }

    func start() -> CallViewController {
        start(replaceExistingEnqueueing: false)
    }

    func start(replaceExistingEnqueueing: Bool) -> CallViewController {
        let viewController = makeCallViewController(
            call: call,
            startAction: startAction,
            replaceExistingEnqueueing: replaceExistingEnqueueing
        )
        return viewController
    }
}

// MARK: - Private

private extension CallCoordinator {
    func makeCallViewController(
        call: Call,
        startAction: CallViewModel.StartAction,
        replaceExistingEnqueueing: Bool
    ) -> CallViewController {
        environment.log.prefixed(Self.self).info("Create Call screen")
        let viewModel = CallViewModel(
            interactor: interactor,
            screenShareHandler: screenShareHandler,
            environment: .create(
                with: environment,
                viewFactory: viewFactory
            ),
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction,
            replaceExistingEnqueueing: replaceExistingEnqueueing
        )
        viewModel.engagementDelegate = { [weak self] event in
            self?.handleEngagementViewModelEvent(event)
        }
        viewModel.delegate = { [weak self] event in
            self?.handleCallViewModelEvent(event)
        }
        return CallViewController(
            viewModel: viewModel,
            environment: .create(
                with: environment,
                viewFactory: viewFactory
            )
        )
    }

    func handleEngagementViewModelEvent(_ event: EngagementViewModel.DelegateEvent) {
        switch event {
        case .back:
            delegate?(.back)
        case let .openLink(link):
            delegate?(.openLink(link))
        case .engaged(let url):
            delegate?(.engaged(operatorImageUrl: url))
        case .finished:
            delegate?(.finished)
        }
    }

    func handleCallViewModelEvent(_ event: CallViewModel.DelegateEvent) {
        switch event {
        case .chat:
            delegate?(.chat)
        case .minimize:
            delegate?(.minimize)
        case .visitorOnHoldUpdated(let isOnHold):
            delegate?(.visitorOnHoldUpdated(isOnHold: isOnHold))
        }
    }
}
