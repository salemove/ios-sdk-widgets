import UIKit

extension CallVisualizer {
    final class VisitorCodeViewController: UIViewController {
        struct Props: Equatable {
            let visitorCodeViewProps: VisitorCodeView.Props
        }

        private let codeView = VisitorCodeView()

        init(props: Props) {
            self.props = props
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var props: Props {
            didSet {
                renderProps()
            }
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            renderProps()
        }

        override func loadView() {
            switch props.visitorCodeViewProps.viewType {
            case .alert:
                view = withContainer(codeView)
            case .embedded:
                view = codeView
            }
        }

        func renderProps() {
            codeView.props = props.visitorCodeViewProps
        }

        private func withContainer(_ view: VisitorCodeView) -> UIView {
            let container = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                container.widthAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, constant: 16)
            ])

            return container
        }
    }
}
