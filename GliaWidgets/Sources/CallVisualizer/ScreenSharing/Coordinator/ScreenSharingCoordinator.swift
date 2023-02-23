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
            var viewController: ScreenSharingViewController?

            let model = ScreenSharingViewModel(
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

            defer { viewModel = model }

            let screenSharingController = ScreenSharingViewController(props: model.props())
            viewController = screenSharingController
            screenSharingController.modalPresentationStyle = .overFullScreen

            return screenSharingController
        }

        private static func createHeaderProps(with header: HeaderStyle) -> Header.Props {
            let backButton = header.backButton.map { HeaderButton.Props(style: $0) }

            return .init(
                title: "",
                effect: .none,
                endButton: .init(),
                backButton: backButton,
                closeButton: .init(style: header.closeButton),
                endScreenshareButton: .init(style: header.endScreenShareButton),
                style: header
            )
        }
    }
}
