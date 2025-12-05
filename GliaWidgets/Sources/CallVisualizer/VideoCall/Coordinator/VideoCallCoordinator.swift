import UIKit

extension CallVisualizer {
    final class VideoCallCoordinator: FlowCoordinator {
        typealias ViewController = UIViewController

        var delegate: ((DelegateEvent) -> Void)?
        private let theme: Theme
        private let environment: Environment
        private(set) var viewModel: VideoCallViewModel?
        let call: Call
        var viewController: VideoCallViewController?

        init(
            environment: Environment,
            theme: Theme,
            call: Call
        ) {
            self.environment = environment
            self.call = call
            self.theme = theme
        }

        func start() -> ViewController {
            return showVideoCallViewController()
        }

        func resume() -> ViewController {
            return resumeVideoCallViewController()
        }

        func close() {
            viewModel?.close()
            viewController?.presentingViewController?.dismiss(animated: true)
        }

        private func showVideoCallViewController() -> ViewController {
            typealias Props = VideoCallViewController.Props

            let viewModel = VideoCallViewModel(
                style: theme.call,
                environment: .create(with: environment),
                call: call
            )
            self.viewModel = viewModel

            let viewController = VideoCallViewController(
                props: viewModel.makeProps(),
                environment: .create(with: environment)
            )
            viewController.modalPresentationStyle = .overFullScreen
            self.viewController = viewController

            viewModel.delegate = { [weak self, weak viewController] event in
                guard let viewController else { return }
                switch event {
                case let .propsUpdated(props):
                    viewController.props = props
                case .minimized:
                    self?.delegate?(.close)
                case let .showSnackBarView(dismissTiming, style):
                    self?.presentNoConnectionSnackBar(
                        from: viewController,
                        dismissTiming: dismissTiming,
                        style: style
                    )
                }
            }
            return viewController
        }

        private func resumeVideoCallViewController() -> ViewController {
            guard let viewModel = viewModel, let viewController = viewController else { return showVideoCallViewController() }

            viewController.modalPresentationStyle = .overFullScreen
            viewModel.delegate = { [weak self, weak viewController] event in
                guard let viewController else { return }
                switch event {
                case let .propsUpdated(props):
                    viewController.props = props
                case .minimized:
                    self?.delegate?(.close)
                case let .showSnackBarView(dismissTiming, style):
                    self?.presentNoConnectionSnackBar(
                        from: viewController,
                        dismissTiming: dismissTiming,
                        style: style
                    )
                }
            }
            return viewController
        }

        private func presentNoConnectionSnackBar(
            from viewController: UIViewController,
            dismissTiming: SnackBar.DismissTiming,
            style: Theme.SnackBarStyle
        ) {
            environment.snackBar.present(
                text: Localization.Snackbar.NoConnection.message,
                style: style,
                dismissTiming: dismissTiming,
                for: viewController,
                bottomOffset: -100,
                timerProviding: environment.timerProviding,
                gcd: environment.gcd,
                notificationCenter: environment.notificationCenter
            )
        }
    }
}
