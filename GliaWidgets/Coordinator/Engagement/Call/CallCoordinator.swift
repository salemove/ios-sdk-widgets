import UIKit
import SalemoveSDK

class CallCoordinator: UIViewControllerCoordinator {
    enum Delegate {
        case chat
        case minimize
        case endScreenShareAlert(confirmed: (() -> Void))
        case startScreenShareAlert(operatorName: String, answer: AnswerBlock)
        case leaveQueueAlert(confirmed: (() -> Void))
        case endEngagementAlert(confirmed: (() -> Void))
    }

    var delegate: ((Delegate) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let call: Call
    private let screenShareHandler: ScreenShareHandler
    private let unreadMessagesHandler: UnreadMessagesHandler

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        call: Call,
        screenShareHandler: ScreenShareHandler,
        unreadMessagesHandler: UnreadMessagesHandler
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.call = call
        self.screenShareHandler = screenShareHandler
        self.unreadMessagesHandler = unreadMessagesHandler
    }

    override func start() -> UIViewController {
        let viewModel = CallViewModel(
            interactor: interactor,
            screenShareHandler: screenShareHandler,
            unreadMessagesHandler: unreadMessagesHandler,
            call: call
        )

        viewModel.alertDelegate = { [weak self] in
            switch $0 {
            case .leaveQueueAlert(let confirmationBlock):
                self?.delegate?(.leaveQueueAlert(confirmed: confirmationBlock))

            case .endEngagementAlert(let confirmationBlock):
                self?.delegate?(.endEngagementAlert(confirmed: confirmationBlock))

            case .startScreenShareAlert(let operatorName, let answer):
                self?.delegate?(.startScreenShareAlert(operatorName: operatorName, answer: answer))

            case .endScreenShareAlert(let confirmationBlock):
                self?.delegate?(.endScreenShareAlert(confirmed: confirmationBlock))

            case .mediaUpgradeAlert:
                break
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
