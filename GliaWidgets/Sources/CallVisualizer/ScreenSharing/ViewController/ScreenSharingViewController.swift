import UIKit

public extension CallVisualizer {
    final class ScreenSharingViewController: UIViewController {
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

        init(props: Props) {
            self.props = props
            super.init(nibName: "", bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Private

private extension CallVisualizer.ScreenSharingViewController {
    func renderProps() {
        screenSharingView.props = props.screenSharingViewProps
    }
}
