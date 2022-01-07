import UIKit
import SalemoveSDK

final class EngagementCoordinator: UIViewControllerCoordinator {
    enum Delegate {
        case minimize
    }

    var delegate: ((Delegate) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let screenShareHandler: ScreenShareHandler
    private let unreadMessagesHandler: UnreadMessagesHandler
    private let engagementKind: EngagementKind

    private weak var presenter: UINavigationController?
    private var alertPresenter: AlertPresenter?

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        screenShareHandler: ScreenShareHandler,
        unreadMessagesHandler: UnreadMessagesHandler,
        engagementKind: EngagementKind
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.screenShareHandler = screenShareHandler
        self.unreadMessagesHandler = unreadMessagesHandler
        self.engagementKind = engagementKind

        super.init()
    }

    override func start() -> Coordinated {
        let rootViewController = createRootViewController()
        let navigationController = EngagementNavigationController(
            rootViewController: rootViewController
        )

        navigationController.setNavigationBarHidden(true, animated: false)

        self.presenter = navigationController
        self.alertPresenter = AlertPresenter(
            rootViewController: navigationController
        )

        return navigationController
    }

    private func createRootViewController() -> Coordinated {
        switch engagementKind {
        case .chat:
            return createChat(showsCallBubble: false)

        case .audioCall:
            return createCall(ofKind: .audio)

        case .videoCall:
            return createCall(ofKind: .video)

        case .none:
            fatalError("EngagementKind cannot be none. Remove once none is deprecated")
        }
    }

    private func createChat(showsCallBubble: Bool) -> Coordinated {
        // TODO: startAction
        let coordinator = ChatCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            showsCallBubble: showsCallBubble,
            screenShareHandler: screenShareHandler,
            unreadMessagesHandler: unreadMessagesHandler,
            startAction: .none
        )

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .back:
                self?.presenter?.popViewController(animated: true)

            case .call:
                self?.presenter?.popViewController(animated: true)

            case .engaged(operatorImageUrl: let operatorImageUrl):
                break

            case .mediaUpgradeAccepted(offer: let offer, answer: let answer):
                break

            case .finished:
                break

            case .leaveQueueAlert(let confirmationBlock):
                self?.presentExitQueue(confirmed: confirmationBlock)

            case .endEngagementAlert(let confirmationBlock):
                self?.presentEndEngagement(confirmed: confirmationBlock)

            case .startScreenShareAlert(let operatorName, let answer):
                self?.presentStartScreenShare(
                    operatorName: operatorName,
                    answer: answer
                )

            case .endScreenShareAlert(let confirmationBlock):
                self?.presentEndScreenShare(confirmed: confirmationBlock)

            case .mediaUpgradeAlert(let offer, let answerBlock):
                self?.presentMediaUpgrade(offer: offer, answer: answerBlock)
            }
        }

        return coordinate(to: coordinator)
    }

    private func createCall(ofKind callKind: CallKind) -> Coordinated {
        let coordinator = CallCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            call: Call(callKind),
            screenShareHandler: screenShareHandler,
            unreadMessagesHandler: unreadMessagesHandler
        )

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .chat:
                if let viewController = self?.createChat(showsCallBubble: true) {
                    self?.presenter?.pushViewController(viewController, animated: true)
                }

            case .minimize:
                self?.delegate?(.minimize)

            case .leaveQueueAlert(let confirmationBlock):
                self?.presentExitQueue(confirmed: confirmationBlock)

            case .endEngagementAlert(let confirmationBlock):
                self?.presentEndEngagement(confirmed: confirmationBlock)

            case .startScreenShareAlert(let operatorName, let answer):
                self?.presentStartScreenShare(
                    operatorName: operatorName,
                    answer: answer
                )

            case .endScreenShareAlert(let confirmationBlock):
                self?.presentEndScreenShare(confirmed: confirmationBlock)
            }
        }

        return coordinate(to: coordinator)
    }
}

extension EngagementCoordinator {
    private func presentMediaUpgrade(
        offer: MediaUpgradeOffer,
        answer: @escaping AnswerWithSuccessBlock
    ) {
        var properties: MediaUpgradeProperties

        switch (offer.type, offer.direction) {
        case (.audio, _):
            properties = MediaUpgradeToAudioAlerProperties(
                configuration: viewFactory.theme.alertConfiguration.audioUpgrade,
                operatorName: "Kuldar-Daniel"
            )

        case (.video, .oneWay):
            properties = MediaUpgradeToAudioAlerProperties(
                configuration: viewFactory.theme.alertConfiguration.oneWayVideoUpgrade,
                operatorName: "Kuldar-Daniel"
            )

        case (.video, .twoWay):
            properties = MediaUpgradeToAudioAlerProperties(
                configuration: viewFactory.theme.alertConfiguration.twoWayVideoUpgrade,
                operatorName: "Kuldar-Daniel"
            )

        default:
            return
        }

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        properties.acceptAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: { [weak self] in
                    guard
                        let self = self,
                        let callKind = CallKind(with: offer)
                    else {
                        answer(false, nil)
                        return
                    }

                    answer(true, nil)

                    self.presenter?.setViewControllers(
                        [self.createCall(ofKind: callKind)],
                        animated: true
                    )
                }
            )
        }

        properties.declineAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: {
                    answer(false, nil)
                }
            )
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentStartScreenShare(
        operatorName: String,
        answer: @escaping AnswerBlock
    ) {
        let properties = StartScreenShareAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.screenShareOffer,
            operatorName: operatorName
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        properties.acceptAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: { answer(true) }
            )
        }

        properties.declineAction.handler = { [weak self] in
            print("decline")
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: { answer(false) }
            )
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentEndEngagement(confirmed: @escaping (() -> Void)) {
        let properties = EndEngagementAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.endEngagement
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        properties.yesAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: { confirmed() }
            )
        }

        properties.noAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: nil
            )
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentExitQueue(confirmed: @escaping (() -> Void)) {
        let properties = ExitQueueAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.leaveQueue
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        properties.yesAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: { confirmed() }
            )
        }

        properties.noAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: nil
            )
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentEndScreenShare(confirmed: @escaping (() -> Void)) {
        let properties = EndScreenShareAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.endScreenShare
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        properties.yesAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: { confirmed() }
            )
        }

        properties.noAction.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: nil
            )
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }
}
