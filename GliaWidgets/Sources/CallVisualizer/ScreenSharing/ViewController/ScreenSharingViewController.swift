import UIKit

public extension CallVisualizer {
    final class ScreenSharingViewController: UIViewController {
        internal init(props: CallVisualizer.ScreenSharingViewController.Props) {
            self.props = props
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private lazy var screenSharingView = ScreenSharingView(props: props.screenSharingViewProps)

        var props: Props {
            didSet {
                renderProps()
            }
        }

        // MARK: - View lifecycle

        public override func loadView() {
            view = screenSharingView
        }
    }
}

// MARK: - Private

private extension CallVisualizer.ScreenSharingViewController {
    func renderProps() {
        screenSharingView.props = props.screenSharingViewProps
    }
}
