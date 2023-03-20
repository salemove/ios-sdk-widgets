import UIKit

extension CallVisualizer {
    final class VideoCallCoodinator: FlowCoordinator {
        typealias ViewController = UIViewController

        var delegate: ((DelegateEvent) -> Void)?
        private let theme: Theme
        private let environment: Environment
        private var viewModel: VideoCallViewModel?
        let call: Call
        var viewController: VideoCallViewController?

        init(
            environment: Environment,
            uiConfig: RemoteConfiguration?,
            call: Call
        ) {
            self.environment = environment
            self.call = call

            if let uiConfig = uiConfig {
                self.theme = Theme(
                    uiConfig: uiConfig,
                    assetsBuilder: .standard
                )
            } else {
                self.theme = Theme()
            }
        }

        func start() -> ViewController {
            return showVideoCallViewController()
        }

        func resume() -> ViewController {
            return resumeVideoCallViewController()
        }

        private func showVideoCallViewController() -> ViewController {
            typealias Props = VideoCallViewController.Props

            let viewModel = VideoCallViewModel(
                style: theme.callStyle,
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache,
                    timerProviding: environment.timerProviding,
                    uiApplication: environment.uiApplication,
                    notificationCenter: environment.notificationCenter,
                    date: environment.date,
                    engagedOperator: environment.engagedOperator,
                    screenShareHandler: environment.screenShareHandler
                ),
                call: call
            )
            self.viewModel = viewModel

            let viewController = VideoCallViewController(
                props: viewModel.makeProps(),
                environment: .init(
                    videoCallView: .init(gcd: environment.gcd),
                    uiApplication: environment.uiApplication,
                    uiScreen: environment.uiScreen,
                    uiDevice: environment.uiDevice,
                    notificationCenter: environment.notificationCenter
                )
            )
            viewController.modalPresentationStyle = .overFullScreen
            self.viewController = viewController

            viewModel.delegate = { [weak self, weak viewController] event in
                switch event {
                case let .propsUpdated(props):
                    viewController?.props = props
                case .minimized:
                    self?.delegate?(.close)
                }
            }
            return viewController
        }

        private func resumeVideoCallViewController() -> ViewController {
            guard let viewModel = viewModel, let viewController = viewController else { return showVideoCallViewController() }

            viewController.modalPresentationStyle = .overFullScreen
            viewModel.delegate = { [weak self, weak viewController] event in
                switch event {
                case let .propsUpdated(props):
                    viewController?.props = props
                case .minimized:
                    self?.delegate?(.close)
                }
            }
            return viewController
        }
    }
}
