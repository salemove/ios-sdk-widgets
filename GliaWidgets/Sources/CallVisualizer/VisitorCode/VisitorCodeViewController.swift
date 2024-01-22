import UIKit

extension CallVisualizer {
    final class VisitorCodeViewController: UIViewController {
        struct Props: Equatable {
            let visitorCodeViewProps: VisitorCodeView.Props
        }

        private let codeView: VisitorCodeView

        init(
            props: Props,
            environment: Environment
        ) {
            self.props = props
            self.codeView = VisitorCodeView(environment: .init(localization: environment.localization))
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
                ),
                view.topAnchor.constraint(
                    greaterThanOrEqualTo: container.topAnchor,
                    constant: 8
                ),
                view.bottomAnchor.constraint(
                    lessThanOrEqualTo: container.bottomAnchor,
                    constant: -8
                )
            ])

            return container
        }
    }
}

extension CallVisualizer.VisitorCodeViewController {
    struct Environment {
        let localization: Localization2.CallVisualizer.VisitorCode
    }
}

#if DEBUG

extension CallVisualizer.VisitorCodeViewController.Environment {
    static let mock = Self(localization: Localization2.mock.callVisualizer.visitorCode)
}

#endif
