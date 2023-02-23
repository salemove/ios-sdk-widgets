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
            let model = ScreenSharingViewModel(
                style: environment.theme.screenSharing,
                environment: .init(screenShareHandler: environment.screenShareHandler)
            )

            defer { viewModel = model }

            let viewController = ScreenSharingViewController(props: model.props())
            viewController.modalPresentationStyle = .overFullScreen

            model.delegate = .init { [weak self, weak viewController] event in
                switch event {
                case .close:
                    viewController?.dismiss(animated: true)
                    self?.delegate?(.close)
                }
            }

            return viewController
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
