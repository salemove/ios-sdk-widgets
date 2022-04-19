import UIKit

final class CallCoordinator: UIViewControllerCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case chat
        case minimize
        case finished
        case mediaUpgradeAccepted(
            offer: CoreSdkClient.MediaUpgradeOffer,
            answer: CoreSdkClient.AnswerWithSuccessBlock
        )
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let call: Call
    private let unreadMessages: ObservableValue<Int>
    private let screenShareHandler: ScreenShareHandler
    private let startAction: CallViewModel.StartAction
    private let environment: Environment

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        call: Call,
        unreadMessages: ObservableValue<Int>,
        screenShareHandler: ScreenShareHandler,
        startAction: CallViewModel.StartAction,
        environment: Environment
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.call = call
        self.unreadMessages = unreadMessages
        self.screenShareHandler = screenShareHandler
        self.startAction = startAction
        self.environment = environment

        super.init(
            environment: .init(
                uuid: environment.uuid
            )
        )
    }

    override func start() -> CallViewController {
        let viewModel = CallViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction,
            environment: .init(
                timerProviding: environment.timerProviding,
                date: environment.date
            )
        )

        viewModel.engagementDelegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.back)
            case .engaged(operatorImageUrl: let url):
                self?.delegate?(.engaged(operatorImageUrl: url))
            case .finished:
                self?.delegate?(.finished)
            }
        }

        viewModel.delegate = { [weak self] event in
            switch event {
            case .chat:
                self?.delegate?(.chat)
            case .minimize:
                self?.delegate?(.minimize)
            case .mediaUpgradeAccepted(let offer, let answer):
                self?.delegate?(.mediaUpgradeAccepted(offer: offer, answer: answer))
            }
        }

        return CallViewController(
            viewModel: viewModel,
            viewFactory: viewFactory
        )
    }
}

extension CallCoordinator {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var date: () -> Date
        var uuid: () -> UUID
    }
}
