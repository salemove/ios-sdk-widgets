import Foundation
import UIKit

extension SecureConversations {
    final class Coordinator: SubFlowCoordinator, FlowCoordinator {
        var delegate: ((DelegateEvent) -> Void)?
        private let viewFactory: ViewFactory

        init(viewFactory: ViewFactory) {
            self.viewFactory = viewFactory
        }

        func start() -> SecureConversations.WelcomeViewController {
            let viewController = makeSecureConversationsWelcomeViewController()

            return viewController
        }

        private func makeSecureConversationsWelcomeViewController() -> SecureConversations.WelcomeViewController {
            let viewModel = SecureConversations.WelcomeViewModel()
            viewModel.delegate = { [weak self] event in
                switch event {
                case .backTapped:
                    self?.delegate?(.backTapped)
                case .closeTapped:
                    self?.delegate?(.closeTapped)

                }
            }
            return SecureConversations.WelcomeViewController(
                viewModel: viewModel,
                viewFactory: viewFactory
            )
        }
    }
}

extension SecureConversations.Coordinator {
    enum DelegateEvent {
        case backTapped
        case closeTapped
    }
}
