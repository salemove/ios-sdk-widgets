import UIKit

extension CallVisualizer {
    final class VideoCallViewController: UIViewController {
        private let videoCallView: VideoCallView
        private let environment: Environment
        private var mediaQualityPresenter: MediaQualityIndicatorPresenter?

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
            mediaQualityPresenter = MediaQualityIndicatorPresenter(
                style: props.videoCallViewProps.style.mediaQualityIndicator,
                parentViewController: self,
                host: videoCallView
            )
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            environment.openTelemetry.logger.i(.callScreenShown)
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            environment.openTelemetry.logger.i(.callScreenClosed)
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

// MARK: - Private

private extension CallVisualizer.VideoCallViewController {
    func renderProps() {
        videoCallView.props = props.videoCallViewProps
    }
}

extension CallVisualizer.VideoCallView: MediaQualityIndicatorHost {
    var mediaQualityIndicatorContainerView: UIView { self }
    var mediaQualityIndicatorTopAnchor: NSLayoutYAxisAnchor { header.bottomAnchor }
}

// MARK: - Network Quality
extension CallVisualizer.VideoCallViewController {
    func setPoorCallQualityIndicatorHidden(_ isHidden: Bool) {
        if isHidden {
            hideMediaQualityIndicator()
        } else {
            showMediaQualityIndicator()
        }
    }

    func showMediaQualityIndicator() {
        mediaQualityPresenter?.show()
    }

    func hideMediaQualityIndicator() {
        mediaQualityPresenter?.hide()
    }
}
