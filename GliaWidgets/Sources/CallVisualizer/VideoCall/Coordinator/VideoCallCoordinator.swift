import UIKit

extension CallVisualizer {
    final class VideoCallCoodinator: FlowCoordinator {
        typealias ViewController = UIViewController

        var delegate: ((DelegateEvent) -> Void)?
        private let theme: Theme
        private let environment: Environment
        private let uiConfig: RemoteConfiguration?
        private var viewModel: VideoCallViewModel?
        let call: Call
        var viewController: VideoCallViewController?

        init(
            theme: Theme = Theme(),
            environment: Environment,
            uiConfig: RemoteConfiguration?,
            call: Call
        ) {
            self.environment = environment
            self.theme = theme
            self.uiConfig = uiConfig
            self.call = call
        }

        func start() -> ViewController {
            return showVideoCallViewController()
        }

        func resume() -> ViewController {
            return resumeVideoCallViewController()
        }

        private func showVideoCallViewController() -> ViewController {
            typealias Props = VideoCallViewController.Props
            if let uiConfig = uiConfig {
                theme.applyRemoteConfiguration(uiConfig, assetsBuilder: .standard)
            }

            let viewModel = VideoCallViewModel(
                style: theme.callStyle,
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache,
                    timerProviding: environment.timerProviding,
                    uiApplication: environment.uiApplication,
                    date: environment.date,
                    engagedOperator: environment.engagedOperator,
                    screenShareHandler: environment.screenShareHandler
                ),
                call: call
            )
            self.viewModel = viewModel

            let viewController = VideoCallViewController(
                props: viewModel.makeProps(),
                environment: .init(gcd: environment.gcd)
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

            if let uiConfig {
                theme.applyRemoteConfiguration(uiConfig, assetsBuilder: .standard)
            }

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
