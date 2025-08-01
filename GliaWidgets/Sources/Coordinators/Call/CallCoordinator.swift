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
    private let startAction: CallViewModel.StartAction
    private let aiScreenContextSummary: (@escaping (AiScreenContext?) -> Void) -> Void
    private let environment: Environment

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        navigationPresenter: NavigationPresenter,
        call: Call,
        unreadMessages: ObservableValue<Int>,
        startAction: CallViewModel.StartAction,
        aiScreenContextSummary: @escaping (@escaping (AiScreenContext?) -> Void) -> Void,
        environment: Environment
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.call = call
        self.unreadMessages = unreadMessages
        self.startAction = startAction
        self.aiScreenContextSummary = aiScreenContextSummary
        self.environment = environment
    }

    func start() -> CallViewController {
        start(replaceExistingEnqueueing: false)
    }

    func start(replaceExistingEnqueueing: Bool) -> CallViewController {
        let viewController = makeCallViewController(
            call: call,
            startAction: startAction,
            replaceExistingEnqueueing: replaceExistingEnqueueing,
            aiScreenContextSummary: aiScreenContextSummary
        )
        return viewController
    }
}

// MARK: - Private

private extension CallCoordinator {
    func makeCallViewController(
        call: Call,
        startAction: CallViewModel.StartAction,
        replaceExistingEnqueueing: Bool,
        aiScreenContextSummary: @escaping (@escaping (AiScreenContext?) -> Void) -> Void
    ) -> CallViewController {
        environment.log.prefixed(Self.self).info("Create Call screen")
        let viewModel = CallViewModel(
            interactor: interactor,
            environment: .create(
                with: environment,
                viewFactory: viewFactory
            ),
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction,
            replaceExistingEnqueueing: replaceExistingEnqueueing,
            aiScreenContextSummary: aiScreenContextSummary
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
