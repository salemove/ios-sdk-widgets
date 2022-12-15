import Foundation
import UIKit

extension SecureConversations {
    final class Coordinator: SubFlowCoordinator, FlowCoordinator {
        var delegate: ((DelegateEvent) -> Void)?
        private let viewFactory: ViewFactory
        private var viewModel: SecureConversations.WelcomeViewModel?

        init(viewFactory: ViewFactory) {
            self.viewFactory = viewFactory
        }

        func start() -> SecureConversations.WelcomeViewController {
            let viewController = makeSecureConversationsWelcomeViewController()

            return viewController
        }

        private func makeSecureConversationsWelcomeViewController() -> SecureConversations.WelcomeViewController {
            let viewModel = SecureConversations.WelcomeViewModel(
                environment: .init(
                    welcomeStyle: viewFactory.theme.secureConversationsWelcomeStyle
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
                }
            }

            // Store view model, so that it would not be deallocated.
            self.viewModel = viewModel

            return controller
        }
    }
}

extension SecureConversations.Coordinator {
    enum DelegateEvent {
        case backTapped
        case closeTapped
    }
}
