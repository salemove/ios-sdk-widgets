import UIKit

public extension CallVisualizer {
    final class ScreenSharingViewController: UIViewController {
        private lazy var screenSharingView = ScreenSharingView(props: props.screenSharingViewProps)

        var props: Props = .initial {
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
