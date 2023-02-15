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
                delegate: .init { [weak self] event in
                    switch event {
                    case let .propsUpdated(props):
                        self?.viewController?.props = props
                    case .minimized:
                        self?.delegate?(.close)

                    }
                },
                call: call
            )
            self.viewModel = viewModel

            let viewController = VideoCallViewController(props: viewModel.makeProps())
            self.viewController = viewController
            return viewController
        }
    }
}
