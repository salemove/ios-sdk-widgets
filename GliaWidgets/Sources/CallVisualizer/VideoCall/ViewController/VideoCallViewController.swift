import UIKit

extension CallVisualizer {
    final class VideoCallViewController: UIViewController {
        private let videoCallView: VideoCallView
        private let environment: Environment

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
            props.viewDidLoad()
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallViewController {
    struct Props: Equatable {
        let videoCallViewProps: CallVisualizer.VideoCallView.Props
        let viewDidLoad: Cmd
    }
}

// MARK: - Environment

extension CallVisualizer.VideoCallViewController {
    struct Environment {
        var videoCallView: CallVisualizer.VideoCallView.Environment
        var notificationCenter: FoundationBased.NotificationCenter
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallViewController {
    func renderProps() {
        videoCallView.props = props.videoCallViewProps
    }
}
