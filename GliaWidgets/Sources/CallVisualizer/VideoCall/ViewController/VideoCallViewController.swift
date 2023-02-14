import UIKit

public extension CallVisualizer {
    final class VideoCallViewController: UIViewController {
        private let videoCallView: VideoCallView

        var props: Props {
            didSet {
                renderProps()
            }
        }

        // MARK: - Initializer

        init(props: Props) {
            self.props = props
            self.videoCallView = .init(props: props.videoCallViewProps)
            super.init(nibName: nil, bundle: nil)
        }

        // MARK: - Required

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Override

        public override func loadView() {
            view = videoCallView
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallViewController {
    struct Props: Equatable {

        let videoCallViewProps: CallVisualizer.VideoCallView.Props

        init(videoCallViewProps: CallVisualizer.VideoCallView.Props) {
            self.videoCallViewProps = videoCallViewProps
        }
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallViewController {
    func renderProps() {
        videoCallView.props = props.videoCallViewProps
    }
}
