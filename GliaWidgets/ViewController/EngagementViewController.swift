import UIKit

class EngagementViewController: ViewController, AlertPresenter {
    internal let viewFactory: ViewFactory
    private let viewModel: EngagementViewModel

    init(viewModel: EngagementViewModel,
         viewFactory: ViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as? EngagementView {
            bind(viewModel: viewModel, to: view)
        }
    }

    private func bind(viewModel: EngagementViewModel, to view: EngagementView) {
        let leftItem = Button(kind: .back, tap: { viewModel.event(.backTapped) })
        let rightItem = Button(kind: .close, tap: { viewModel.event(.closeTapped) })
        view.header.setLeftItem(leftItem, animated: false)
        view.header.setRightItem(rightItem, animated: false)

        viewModel.engagementAction = { action in
            switch action {
            case .showEndButton:
                let rightItem = ActionButton(with: self.viewFactory.theme.chat.endButton)
                rightItem.tap = { viewModel.event(.closeTapped) }
                view.header.setRightItem(rightItem, animated: true)
            case .confirm(let conf, confirmed: let confirmed):
                self.presentConfirmation(with: conf) { confirmed?() }
            case .showAlert(let conf, dismissed: let dismissed):
                self.presentAlert(with: conf) { dismissed?() }
            case .showSettingsAlert(let conf, cancelled: let cancelled):
                self.presentSettingsAlert(with: conf, cancelled: cancelled)
            }
        }
    }
}
