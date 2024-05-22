import UIKit

extension CallVisualizer {
    class VisitorCodeCoordinator: FlowCoordinator {
        typealias ViewController = UIViewController

        let theme: Theme
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment
        let presentation: CallVisualizer.Presentation
        var viewModel: VisitorCodeViewModel?
        var codeViewController: VisitorCodeViewController?

        init(
            theme: Theme,
            environment: Environment,
            presentation: CallVisualizer.Presentation
        ) {
            self.environment = environment
            self.theme = theme
            self.presentation = presentation
        }

        @discardableResult
        func start() -> UIViewController {
            showVisitorCodeViewController(by: presentation)
        }

        func showVisitorCodeViewController(by presentation: CallVisualizer.Presentation) -> UIViewController {
            let viewModel = VisitorCodeViewModel(
                presentation: presentation,
                environment: .init(
                    timerProviding: environment.timerProviding,
                    requestVisitorCode: environment.requestVisitorCode
                ),
                theme: theme,
                delegate: { [weak self] action in
                    switch action {
                    case let .propsUpdated(props):
                        self?.codeViewController?.props = props
                    case .closeButtonTap:
                        self?.codeViewController?.presentingViewController?.dismiss(animated: true)
                        self?.delegate?(.closeTap)
                    }
                }
            )

            viewModel.requestVisitorCode()
            self.viewModel = viewModel

            let codeController = VisitorCodeViewController(props: viewModel.makeProps())
            self.codeViewController = codeController

            switch presentation {
            case .alert(let parentController):
                codeController.modalPresentationStyle = .overFullScreen
                codeController.modalTransitionStyle = .crossDissolve
                parentController.present(codeController, animated: true)
            case .embedded(let parentView, _):
                parentView.subviews.forEach { $0.removeFromSuperview() }
                parentView.addSubview(codeController.view)
                codeController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    codeController.view.widthAnchor.constraint(equalTo: parentView.widthAnchor),
                    codeController.view.heightAnchor.constraint(equalTo: parentView.heightAnchor),
                    codeController.view.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                    codeController.view.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
                ])
            }

            return codeController
        }
    }
}
