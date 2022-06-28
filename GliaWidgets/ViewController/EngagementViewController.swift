import UIKit

class EngagementViewController: ViewController, AlertPresenter {
    internal let viewFactory: ViewFactory
    private let viewModel: EngagementViewModel

    init(viewModel: EngagementViewModel, viewFactory: ViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory

        super.init(nibName: nil, bundle: nil)

        // bind it here, so that view property will be requested from subclasses and views created
        bind(engagementViewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.event(.viewWillAppear)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.event(.viewDidAppear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.event(.viewDidDisappear)
    }

    func bind(engagementViewModel: EngagementViewModel) {
        guard let view = view as? EngagementView else { return }

        view.header.endButton.tap = { [weak self] in self?.viewModel.event(.closeTapped) }
        view.header.endScreenShareButton.tap = { [weak self] in self?.viewModel.event(.endScreenSharingTapped) }
        view.header.backButton.tap = { [weak self] in self?.viewModel.event(.backTapped) }
        view.header.closeButton.tap = { [weak self] in self?.viewModel.event(.closeTapped) }

        viewModel.engagementAction = { action in
            switch action {
            case .confirm(let conf, confirmed: let confirmed):
                self.presentConfirmation(with: conf) { confirmed?() }
            case .showSingleActionAlert(let conf, actionTapped: let actionTapped):
                self.presentSingleActionAlert(with: conf) { actionTapped?() }
            case .showAlert(let conf, dismissed: let dismissed):
                self.presentAlert(with: conf) { dismissed?() }
            case .showSettingsAlert(let conf, cancelled: let cancelled):
                self.presentSettingsAlert(with: conf, cancelled: cancelled)
            case .offerScreenShare(let conf, accepted: let accepted, declined: let declined):
                self.offerScreenShare(with: conf, accepted: accepted, declined: declined)
            case .showEndButton:
                view.header.showEndButton()
            case .showEndScreenShareButton:
                view.header.showEndScreenSharingButton()
            }
        }
    }
}
