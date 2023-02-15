import UIKit

extension CallVisualizer {
    final class VideoCallCoodinator: FlowCoordinator {
        typealias ViewController = UIViewController
        private let theme: Theme

        var delegate: ((DelegateEvent) -> Void)?
        let environment: Environment
        let call: Call
        let uiConfig: RemoteConfiguration?
        var viewModel: VideoCallViewModel?

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

        private func showVideoCallViewController() -> ViewController {
            typealias Props = VideoCallViewController.Props
            if let uiConfig {
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

            let viewController = VideoCallViewController(props: viewModel.makeProps())
            viewController.modalPresentationStyle = .fullScreen

            viewModel.delegate = { [weak self, weak viewController] event in
                switch event {
                case let .propsUpdated(props):
                    viewController?.props = props
                case .minimized:
                    viewController?.dismiss(animated: true)
                    self?.delegate?(.close)
                }
            }
            return viewController
        }
    }
}
