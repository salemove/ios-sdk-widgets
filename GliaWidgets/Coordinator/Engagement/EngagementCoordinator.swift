import UIKit
import SalemoveSDK

final class EngagementCoordinator: UIViewControllerCoordinator {
    enum Delegate {
        case minimize
        case engaged(operatorImageUrl: String?)
        case finished
    }

    var delegate: ((Delegate) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let screenShareHandler: ScreenShareHandler
    private let engagementKind: EngagementKind
    private let messageDispatcher: MessageDispatcher

    private weak var presenter: UINavigationController?
    private var alertPresenter: AlertPresenter?

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        screenShareHandler: ScreenShareHandler,
        engagementKind: EngagementKind,
        messageDispatcher: MessageDispatcher
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.screenShareHandler = screenShareHandler
        self.engagementKind = engagementKind
        self.messageDispatcher = messageDispatcher

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
            return createChat(startAction: .startEngagement)

        case .audioCall:
            return createCall(ofKind: .audio, startAction: .startEngagement(mediaType: .audio))

        case .videoCall:
            return createCall(ofKind: .video, startAction: .startEngagement(mediaType: .video))

        case .none:
            fatalError("EngagementKind cannot be none.")
        }
    }

    private func createChat(
        startAction: ChatViewModel.StartAction
    ) -> Coordinated {
        let coordinator = ChatCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            showsCallBubble: startAction == .none,
            screenShareHandler: screenShareHandler,
            messageDispatcher: messageDispatcher,
            startAction: startAction
        )

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .back:
                if self?.presenter?.viewControllers.count == 1 {
                    self?.delegate?(.minimize)
                } else {
                    self?.presenter?.popViewController(animated: true)
                }

            case .callBubbleTapped:
                self?.presenter?.popViewController(animated: true)

            case .engaged(let operatorImageUrl):
                self?.delegate?(.engaged(operatorImageUrl: operatorImageUrl))

            case .finished:
                self?.delegate?(.finished)

            case .alert(let alert):
                self?.presentAlert(alert: alert)
            }
        }

        return coordinate(to: coordinator)
    }

    private func createCall(
        ofKind callKind: CallKind,
        startAction: CallViewModel.StartAction
    ) -> Coordinated {
        let call = Call(callKind)
        let coordinator = CallCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            call: call,
            screenShareHandler: screenShareHandler,
            unreadMessagesCounter: messageDispatcher,
            startAction: startAction
        )

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .chat:
                if let viewController = self?.createChat(startAction: .none) {
                    self?.presenter?.pushViewController(viewController, animated: true)
                }

            case .minimize:
                self?.delegate?(.minimize)

            case .back:
                if self?.presenter?.viewControllers.count == 1 {
                    self?.delegate?(.minimize)
                } else {
                    self?.presenter?.popViewController(animated: true)
                }

            case .engaged(operatorImageUrl: let operatorImageUrl):
                self?.delegate?(.engaged(operatorImageUrl: operatorImageUrl))

            case .finished:
                self?.delegate?(.finished)

            case .alert(let alert):
                self?.presentAlert(alert: alert)
            }
        }

        return coordinate(to: coordinator)
    }
}

extension EngagementCoordinator {
    private func presentAlert(alert: Alert) {
        switch alert {
        case .leaveQueueAlert(let confirmed):
            presentExitQueue(confirmed: confirmed)

        case .endEngagementAlert(let confirmed):
            presentEndEngagement(confirmed: confirmed)

        case .operatorEndedEngagement:
            presentOperatorEndedEngagement()

        case .mediaUpgradeAlert(let offer, let answer, let operatorName):
            presentMediaUpgrade(offer: offer, answer: answer, operatorName: operatorName)

        case .mediaSourceError:
            presentMediaSourceErrorAlert()

        case .endScreenShareAlert(let confirmed):
            presentEndScreenShare(confirmed: confirmed)

        case .startScreenShareAlert(let answer, let operatorName):
            presentStartScreenShare(answer: answer, operatorName: operatorName)

        case .cameraSettings:
            break

        case .microphoneSettings:
            break

        case .operatorsUnavailable:
            presentOperatorsUnavailable()

        case .unexpectedError:
            presentUnexpectedError()

        case .apiError:
            presentApiError()
        }
    }
}

extension EngagementCoordinator {
    private func presentOperatorEndedEngagement() {
        let properties = EngagementEndedAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.operatorEndedEngagement
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        properties.action.handler = { [weak self] in
            self?.alertPresenter?.dismiss(
                view: viewController,
                animated: true,
                completion: { [weak self] in
                    self?.delegate?(.finished)
                }
            )
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentMediaSourceErrorAlert() {
        let properties = MediaSourceErrorAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.mediaSourceNotAvailable
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .dismiss:
                self?.alertPresenter?.dismiss(
                    view: viewController,
                    animated: true,
                    completion: nil
                )
            }
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentOperatorsUnavailable() {
        let properties = OperatorsUnavailableAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.operatorsUnavailable
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .dismiss:
                self?.alertPresenter?.dismiss(
                    view: viewController,
                    animated: true,
                    completion: nil
                )
            }
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentUnexpectedError() {
        let properties = UnexpectedErrorAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.unexpectedError
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .dismiss:
                self?.alertPresenter?.dismiss(
                    view: viewController,
                    animated: true,
                    completion: nil
                )
            }
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentApiError() {
        let properties = APIErrorAlertProperties(
            configuration: viewFactory.theme.alertConfiguration.apiError
        )

        let coordinator = AlertCoordinator(
            properties: properties,
            viewFactory: viewFactory
        )

        let viewController = coordinate(to: coordinator)

        coordinator.delegate = { [weak self] in
            switch $0 {
            case .dismiss:
                self?.alertPresenter?.dismiss(
                    view: viewController,
                    animated: true,
                    completion: nil
                )
            }
        }

        alertPresenter?.present(
            view: viewController,
            animated: true,
            completion: nil
        )
    }

    private func presentMediaUpgrade(
        offer: MediaUpgradeOffer,
        answer: @escaping AnswerWithSuccessBlock,
        operatorName: String
    ) {
        var properties: MediaUpgradeProperties

        switch (offer.type, offer.direction) {
        case (.audio, _):
            properties = MediaUpgradeToAudioAlerProperties(
                configuration: viewFactory.theme.alertConfiguration.audioUpgrade,
                operatorName: operatorName
            )

        case (.video, .oneWay):
            properties = MediaUpgradeToOneWayVideoAlertProperties(
                configuration: viewFactory.theme.alertConfiguration.oneWayVideoUpgrade,
                operatorName: operatorName
            )

        case (.video, .twoWay):
            properties = MediaUpgradeToTwoWayVideoAlertProperties(
                configuration: viewFactory.theme.alertConfiguration.twoWayVideoUpgrade,
                operatorName: operatorName
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
                        [
                            self.createCall(
                                ofKind: callKind,
                                startAction: .fromUpgrade
                            )
                        ],
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
        answer: @escaping AnswerBlock,
        operatorName: String
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
