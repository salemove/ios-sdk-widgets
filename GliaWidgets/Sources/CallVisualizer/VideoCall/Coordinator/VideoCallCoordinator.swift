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

        func minimize() {
            viewController?.presentingViewController?.dismiss(animated: true)
        }

        func finish() {
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
                    self?.delegate?(.minimize)
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
                    self?.delegate?(.minimize)
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
                configuration: .anchor(
                    anchorViewProvider: { [weak viewController] in
                        guard let videoCallView = viewController?.view as? CallVisualizer.VideoCallView else {
                            return nil
                        }
                        return videoCallView.buttonBar
                    },
                    gap: 16
                ),
                timerProviding: environment.timerProviding,
                gcd: environment.gcd
            )
        }
    }
}
