import UIKit

class EngagementViewController: UIViewController, AlertPresenter {
    let viewFactory: ViewFactory
    private var viewModel: CommonEngagementModel

    init(viewModel: CommonEngagementModel, viewFactory: ViewFactory) {
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

    func bind(engagementViewModel: CommonEngagementModel) {
        guard let view = view as? EngagementView else { return }

        viewModel.engagementAction = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .confirm(let conf, let accessibilityIdentifier, confirmed: let confirmed):
                self.presentConfirmation(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier
                ) { confirmed?() }
            case .showSingleActionAlert(let conf, let accessibilityIdentifier, let actionTapped):
                self.presentSingleActionAlert(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier
                ) { actionTapped?() }
            case .showAlert(let conf, let accessibilityIdentifier, dismissed: let dismissed):
                self.presentAlert(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier
                ) { dismissed?() }
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

    func swapAndBindEgagementViewModel(_ engagementModel: CommonEngagementModel) {
        self.viewModel = engagementModel
        bind(engagementViewModel: engagementModel)
    }
}
