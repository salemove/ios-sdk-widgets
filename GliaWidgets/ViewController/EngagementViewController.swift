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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.event(.viewDidAppear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.event(.viewDidDisappear)
    }

    func showBackButton(with style: HeaderButtonStyle, in header: Header) {
        let back = HeaderButton(with: style, tap: { self.viewModel.event(.backTapped) })
        back.contentHorizontalAlignment = .left
        header.setLeftItem(back, animated: false)
    }

    func showCloseButton(with style: HeaderButtonStyle, in header: Header) {
        let back = HeaderButton(with: style, tap: { self.viewModel.event(.closeTapped) })
        back.contentHorizontalAlignment = .right
        header.setRightItem(back, animated: false)
    }

    private func bind(viewModel: EngagementViewModel, to view: EngagementView) {
        viewModel.engagementAction = { action in
            switch action {
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
