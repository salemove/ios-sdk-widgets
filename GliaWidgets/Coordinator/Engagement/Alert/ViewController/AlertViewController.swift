import UIKit

final class AlertViewController: UIViewController {
    private let viewModel: AlertViewModel
    private let viewFactory: ViewFactory

    init(
        viewModel: AlertViewModel,
        viewFactory: ViewFactory
    ) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = viewFactory.makeAlertView()
        self.view = view

        var input = AlertViewModel.Input()
        let output = viewModel.transform(&input)

        bind(view, to: input)
        bind(output, to: view)
    }

    private func bind(_ output: AlertViewModel.Output, to view: AlertView) {
        view.configure(for: output.properties.items)
        view.configure(for: output.properties.showsCloseButton)
    }

    private func bind(_ view: AlertView, to input: AlertViewModel.Input) {
        view.dismiss = { input.dismiss?() }
    }
}
