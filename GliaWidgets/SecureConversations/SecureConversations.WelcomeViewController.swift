import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeViewController: ViewController {
        private let viewModel: SecureConversations.WelcomeViewModel
        private let viewFactory: ViewFactory

        init(
            viewModel: SecureConversations.WelcomeViewModel,
            viewFactory: ViewFactory
        ) {
            self.viewModel = viewModel
            self.viewFactory = viewFactory

            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func loadView() {
            let view = viewFactory.makeSecureConversationsWelcomeView()
            self.view = view

            bind(viewModel: viewModel, to: view)
        }

        private func bind(
            viewModel: SecureConversations.WelcomeViewModel,
            to view: SecureConversations.WelcomeView
        ) {
            view.header.showCloseButton()

            view.header.backButton.tap = { [weak viewModel] in
                viewModel?.event(.backTapped)
            }

            view.header.closeButton.tap = { [weak viewModel] in
                viewModel?.event(.closeTapped)
            }
        }
    }
}
