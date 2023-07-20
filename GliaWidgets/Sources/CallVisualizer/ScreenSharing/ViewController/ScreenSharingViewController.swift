import UIKit

extension CallVisualizer {
    final class ScreenSharingViewController: UIViewController {
        private lazy var screenSharingView = ScreenSharingView(props: props.screenSharingViewProps)
        private var props: Props

        // MARK: - Initialization

        init(props: Props) {
            self.props = props
            super.init(nibName: "", bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - View lifecycle

        override func loadView() {
            view = screenSharingView
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            renderProps()
        }
    }
}

// MARK: - Private

private extension CallVisualizer.ScreenSharingViewController {
    func renderProps() {
        screenSharingView.props = props.screenSharingViewProps
    }
}
