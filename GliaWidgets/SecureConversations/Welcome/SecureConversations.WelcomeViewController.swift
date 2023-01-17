import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeViewController: UIViewController {
        var props: Props {
            didSet {
                guard props != oldValue else { return }
                renderProps()
            }
        }

        private let viewFactory: ViewFactory

        init(
            viewFactory: ViewFactory,
            props: Props
        ) {
            self.viewFactory = viewFactory
            self.props = props
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
                welcomeView = viewFactory.makeSecureConversationsWelcomeView(props: props)
                view = welcomeView
            }
            welcomeView.props = props
        }
    }
}

extension SecureConversations.WelcomeViewController {
    enum Props: Equatable {
        case welcome(SecureConversations.WelcomeView.Props)
    }
}
