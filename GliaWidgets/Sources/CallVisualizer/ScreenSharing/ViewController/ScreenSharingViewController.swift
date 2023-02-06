import UIKit

public extension CallVisualizer {
    final class ScreenSharingViewController: UIViewController {
        private let screenSharingView = ScreenSharingView()

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
