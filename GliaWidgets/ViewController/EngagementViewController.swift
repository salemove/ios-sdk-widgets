import UIKit

class EngagementViewController: ViewController, AlertPresenter {
    internal let viewFactory: ViewFactory
    private let viewModel: EngagementViewModel

    init(viewModel: EngagementViewModel,
         viewFactory: ViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(nibName: nil, bundle: nil)
        bind(to: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind(to viewModel: EngagementViewModel) {
        viewModel.engagementAction = { action in
            switch action {
            case .confirm(let conf, confirmed: let confirmed):
                self.presentConfirmation(with: conf) { confirmed?() }
            case .showAlert(let conf, dismissed: let dismissed):
                self.presentAlert(with: conf) { dismissed?() }
            }
        }
    }
}
