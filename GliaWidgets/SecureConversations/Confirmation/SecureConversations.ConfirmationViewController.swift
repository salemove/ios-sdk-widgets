import UIKit

extension SecureConversations {
    final class ConfirmationViewController: UIViewController {
        var props: Props {
            didSet {
                guard props != oldValue else { return }
                renderProps()
            }
        }

        private let viewFactory: ViewFactory
        private let viewModel: ConfirmationViewModel

        init(
            viewModel: ConfirmationViewModel,
            viewFactory: ViewFactory,
            props: Props
        ) {
            self.viewModel = viewModel
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
            let confirmationView: ConfirmationView
            if let currentView = view as? ConfirmationView {
                confirmationView = currentView
            } else {
                confirmationView = viewFactory.makeSecureConversationsConfirmationView(
                    props: props.confirmationViewProps
                )
                view = confirmationView
            }
            confirmationView.props = props.confirmationViewProps
        }
    }
}

extension SecureConversations.ConfirmationViewController {
    struct Props: Equatable {
        let confirmationViewProps: SecureConversations.ConfirmationView.Props
    }
}
