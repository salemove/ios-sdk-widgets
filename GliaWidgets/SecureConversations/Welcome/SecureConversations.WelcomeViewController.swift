import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeViewController: UIViewController {
        var props: Props {
            didSet {
                renderProps()
            }
        }

        let viewFactory: ViewFactory
        let environment: Environment
        private let viewModel: WelcomeViewModel

        init(
            viewFactory: ViewFactory,
            viewModel: WelcomeViewModel,
            props: Props,
            environment: Environment
        ) {
            self.viewFactory = viewFactory
            self.props = props
            self.environment = environment
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func loadView() {
            super.loadView()
            renderProps()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            viewModel.event(.viewDidAppear)
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            viewModel.event(.viewDidDisappear)
        }

        func renderProps() {
            switch props {
            case let .welcome(welcomeProps):
                renderWelcome(props: welcomeProps)
            }
        }

        func renderWelcome(props: WelcomeView.Props) {
            let welcomeView: WelcomeView
            if let currentView = view as? WelcomeView {
                welcomeView = currentView
            } else {
                welcomeView = viewFactory.makeSecureConversationsWelcomeView(
                    props: props,
                    environment: .create(with: environment)
                )
                view = welcomeView
            }
            welcomeView.props = props
        }

        deinit {
            environment.log.prefixed(Self.self).info("Destroy Message Center screen")
        }
    }
}

extension SecureConversations.WelcomeViewController {
    enum Props: Equatable {
        case welcome(SecureConversations.WelcomeView.Props)
    }
}

extension SecureConversations.WelcomeViewController: PopoverPresenter {}
