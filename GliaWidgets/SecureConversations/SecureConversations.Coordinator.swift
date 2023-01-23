import Foundation
import UIKit

extension SecureConversations {
    final class Coordinator: SubFlowCoordinator, FlowCoordinator {
        var delegate: ((DelegateEvent) -> Void)?
        private let viewFactory: ViewFactory
        private let navigationPresenter: NavigationPresenter
        private let environment: Environment
        private var viewModel: SecureConversations.WelcomeViewModel?

        init(
            viewFactory: ViewFactory,
            navigationPresenter: NavigationPresenter,
            environment: Environment
        ) {
            self.viewFactory = viewFactory
            self.navigationPresenter = navigationPresenter
            self.environment = environment
        }

        func start() -> UIViewController {
            let viewController = makeSecureConversationsWelcomeViewController()

            return viewController
        }

        private func makeSecureConversationsWelcomeViewController() -> SecureConversations.WelcomeViewController {
            let viewModel = SecureConversations.WelcomeViewModel(
                environment: .init(
                    welcomeStyle: viewFactory.theme.secureConversationsWelcomeStyle,
                    queueIds: environment.queueIds,
                    sendSecureMessage: environment.sendSecureMessage
                )
            )

            let controller = SecureConversations.WelcomeViewController(
                viewFactory: viewFactory,
                props: viewModel.props()
            )

            viewModel.delegate = { [weak self, weak controller] event in
                switch event {
                case .backTapped:
                    self?.delegate?(.backTapped)
                case .closeTapped:
                    self?.delegate?(.closeTapped)
                // Bind changes in view model to view controller.
                case let .renderProps(props):
                    controller?.props = props
                case .confirmationScreenNeeded:
                    self?.presentSecureConversationsConfirmationViewController()
                }
            }

            // Store view model, so that it would not be deallocated.
            self.viewModel = viewModel

            return controller
        }

        func presentSecureConversationsConfirmationViewController() {
            let viewModel = SecureConversations.ConfirmationViewModel(
                environment: .init(
                    confirmationStyle: viewFactory.theme.secureConversationsConfirmationStyle
                )
            )

            let controller = SecureConversations.ConfirmationViewController(
                viewModel: viewModel,
                viewFactory: viewFactory,
                props: viewModel.props()
            )

            viewModel.delegate = { [weak self, weak controller] event in
                switch event {
                case .backTapped:
                    self?.delegate?(.backTapped)
                case .closeTapped:
                    self?.delegate?(.closeTapped)
                // Bind changes in view model to view controller.
                case let .renderProps(props):
                    controller?.props = props
                }
            }

            self.navigationPresenter.push(
                controller,
                animated: true,
                replacingLast: true
            )
        }
    }
}

extension SecureConversations.Coordinator {
    struct Environment {
        var queueIds: [String]
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
    }

    enum DelegateEvent {
        case backTapped
        case closeTapped
    }
}
