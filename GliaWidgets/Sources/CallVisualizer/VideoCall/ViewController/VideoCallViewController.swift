import UIKit

extension CallVisualizer {
    final class VideoCallViewController: UIViewController {
        private let videoCallView: VideoCallView
        private let environment: Environment
        private var proximityManager: ProximityManager?

        var props: Props {
            didSet {
                renderProps()
            }
        }

        // MARK: - Initializer

        init(props: Props, environment: Environment) {
            self.props = props
            self.videoCallView = .init(
                props: props.videoCallViewProps,
                environment: environment.videoCallView
            )
            self.environment = environment
            super.init(nibName: nil, bundle: nil)
        }

        deinit {
            proximityManager?.stop()
        }

        // MARK: - Required

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Override

        override func loadView() {
            view = videoCallView
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            proximityManager = .init(
                view: self.view,
                environment: .init(
                    uiApplication: environment.uiApplication,
                    uiDevice: environment.uiDevice,
                    uiScreen: environment.uiScreen,
                    notificationCenter: environment.notificationCenter
                )
            )
            proximityManager?.start()
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallViewController {
    struct Props: Equatable {
        let videoCallViewProps: CallVisualizer.VideoCallView.Props
    }
}

// MARK: - Environment

extension CallVisualizer.VideoCallViewController {
    struct Environment {
        var videoCallView: CallVisualizer.VideoCallView.Environment
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var uiDevice: UIKitBased.UIDevice
        var notificationCenter: FoundationBased.NotificationCenter
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallViewController {
    func renderProps() {
        videoCallView.props = props.videoCallViewProps
    }
}
