import UIKit

extension CallVisualizer {
    final class ScreenSharingCoordinator: FlowCoordinator {
        typealias ViewController = UIViewController

        var delegate: ((DelegateEvent) -> Void)?

        private let environment: Environment
        private var viewModel: ScreenSharingView.Model?
        var viewController: ScreenSharingViewController?

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
            self.environment.log.prefixed(Self.self).info("Create End Screen Sharing screen")
            let environment: ScreenSharingView.Model.Environment = .init(
                orientationManager: self.environment.orientationManager,
                uiApplication: .live,
                screenShareHandler: environment.screenShareHandler,
                log: environment.log
            )
            let model: ScreenSharingView.Model = .init(
                style: self.environment.theme.screenSharing,
                environment: environment
            )

            self.viewModel = model

            let viewController: ScreenSharingViewController = .init(model: model)
            viewController.modalPresentationStyle = .overFullScreen
            self.viewController = viewController

            model.delegate = .init { [weak self, weak viewController] event in
                switch event {
                case .closeTapped:
                    viewController?.dismiss(animated: true)
                    self?.delegate?(.close)
                }
            }

            return viewController
        }
    }
}
