extension SecureConversations {
    final class TranscriptCoordinator: FlowCoordinator {

        typealias ViewController = ChatViewController

        enum DelegateEvent {

        }

        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        init(environment: Environment) {
            self.environment = environment
        }

        func start() -> ChatViewController {
            let model = TranscriptModel()
            let controller = ChatViewController(
                viewModel: .transcript(model), viewFactory: environment.viewFactory
            )
            return controller
        }
    }
}

extension SecureConversations.TranscriptCoordinator {
    struct Environment {
        var viewFactory: ViewFactory
    }
}
