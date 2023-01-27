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
            view = withContainer(codeView)
        }

        func renderProps() {
            codeView.props = props.visitorCodeViewProps
        }

        private func withContainer(_ view: VisitorCodeView) -> UIView {
            let container = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            NSLayoutConstraint.activate([
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.leadingAnchor.constraint(
                    equalTo: container.safeAreaLayoutGuide.leadingAnchor,
                    constant: 8
                ),
                view.trailingAnchor.constraint(
                    equalTo: container.safeAreaLayoutGuide.trailingAnchor,
                    constant: -8
                )
            ])

            return container
        }
    }
}
