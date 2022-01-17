import UIKit
import SalemoveSDK

class CallCoordinator: UIViewControllerCoordinator {
    enum Delegate {
        case chat
        case back
        case minimize
        case engaged(operatorImageUrl: String?)
        case finished
        case alert(Alert)
    }

    var delegate: ((Delegate) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let call: Call
    private let screenShareHandler: ScreenShareHandler
    private let unreadMessagesCounter: UnreadMessagesCounter
    private let startAction: CallViewModel.StartAction

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        call: Call,
        screenShareHandler: ScreenShareHandler,
        unreadMessagesCounter: UnreadMessagesCounter,
        startAction: CallViewModel.StartAction
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.call = call
        self.screenShareHandler = screenShareHandler
        self.unreadMessagesCounter = unreadMessagesCounter
        self.startAction = startAction
    }

    override func start() -> UIViewController {
        let viewModel = CallViewModel(
            interactor: interactor,
            screenShareHandler: screenShareHandler,
            unreadMessagesCounter: unreadMessagesCounter,
            call: call,
            startAction: startAction
        )

        viewModel.engagementDelegate = { [weak self] in
            switch $0 {
            case .back:
                self?.delegate?(.back)

            case .engaged(let operatorImageUrl):
                self?.delegate?(.engaged(operatorImageUrl: operatorImageUrl))

            case .finished:
                self?.delegate?(.finished)

            case .alert(let alert):
                self?.delegate?(.alert(alert))
            }
        }

        viewModel.delegate = { [weak self] event in
            switch event {
            case .chat:
                self?.delegate?(.chat)

            case .minimize:
                self?.delegate?(.minimize)
            }
        }

        return CallViewController(
            viewModel: viewModel,
            viewFactory: viewFactory
        )
    }
}
