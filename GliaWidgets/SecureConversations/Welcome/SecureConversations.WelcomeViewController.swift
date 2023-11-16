import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeViewController: UIViewController {
        struct Environemnt {
            let gcd: GCD
            let uiScreen: UIKitBased.UIScreen
            let notificationCenter: FoundationBased.NotificationCenter
        }
        var props: Props {
            didSet {
                renderProps()
            }
        }

        let viewFactory: ViewFactory
        let environment: Environemnt

        init(
            viewFactory: ViewFactory,
            props: Props,
            environment: Environemnt
        ) {
            self.viewFactory = viewFactory
            self.props = props
            self.environment = environment
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
                welcomeView = viewFactory.makeSecureConversationsWelcomeView(
                    props: props,
                    environment: .init(
                        gcd: environment.gcd,
                        uiScreen: environment.uiScreen,
                        notificationCenter: environment.notificationCenter
                    )
                )
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

extension SecureConversations.WelcomeViewController: PopoverPresenter {}

extension SecureConversations.WelcomeViewController: AlertPresenter {}
