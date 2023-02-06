import UIKit

extension CallVisualizer {
    final class ScreenSharingCoordinator: FlowCoordinator {
        typealias ViewController = UIViewController
        var delegate: ((DelegateEvent) -> Void)?

        private let environment: Environment
        private var viewModel: ScreenSharingViewModel?

        // MARK: - Initialization

        init(environment: Environment) {
            self.environment = environment
        }

        // MARK: - FlowCoordinator

        func start() -> ViewController {
            return showEndScreenSharingViewController()
        }

        // MARK: - Private

        private func showEndScreenSharingViewController() -> ViewController {
            typealias Props = ScreenSharingViewController.Props

            let viewController = ScreenSharingViewController()
            viewController.modalPresentationStyle = .overFullScreen

            viewModel = ScreenSharingViewModel(
                style: environment.theme.screenSharing,
                delegate: .init { [weak self, weak viewController] event in
                    switch event {
                    case .close:
                        viewController?.dismiss(animated: true)
                        self?.delegate?(.close)
                    case let .propsUpdated(props):
                        viewController?.props = props
                    }
                },
                environment: .init(screenShareHandler: environment.screenShareHandler)
            )
            return viewController
        }
    }
}
