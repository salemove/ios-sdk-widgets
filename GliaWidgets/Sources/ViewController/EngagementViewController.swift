import UIKit

class EngagementViewController: UIViewController, AlertPresenter {
    var viewFactory: ViewFactory {
        environment.viewFactory
    }
    private let environment: Environment
    private var viewModel: CommonEngagementModel
    private var pendingLiveObservationConfirmation: LiveObservation.Confirmation?

    init(
        viewModel: CommonEngagementModel,
        environment: Environment
    ) {
        self.viewModel = viewModel
        self.environment = environment

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
        viewModel.setViewAppeared()
        if let alertConfig = pendingLiveObservationConfirmation {
            showLiveObservationConfirmationAlert(with: alertConfig)
            pendingLiveObservationConfirmation = nil
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.event(.viewDidDisappear)
    }

    func bind(engagementViewModel: CommonEngagementModel) {
        guard let view = view as? EngagementView else { return }

        viewModel.engagementAction = { [weak self, weak view] action in
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
            case .showEndButton:
                view?.header.showEndButton()
            case .showEndScreenShareButton:
                view?.header.showEndScreenSharingButton()
            case let .showLiveObservationConfirmation(configuration):
                self.showLiveObservationConfirmation(with: configuration)
            }
        }
    }

    func swapAndBindEgagementViewModel(_ engagementModel: CommonEngagementModel) {
        self.viewModel = engagementModel
        bind(engagementViewModel: engagementModel)
    }

    private func showLiveObservationConfirmation(
        with config: LiveObservation.Confirmation
    ) {
        switch viewModel.hasViewAppeared {
        case true: showLiveObservationConfirmationAlert(with: config)
        case false: pendingLiveObservationConfirmation = config
        }
    }

    private func showLiveObservationConfirmationAlert(with config: LiveObservation.Confirmation) {
        let alert = AlertViewController(
            kind: .liveObservationConfirmation(
                config.conf,
                link: config.link,
                accepted: config.accepted,
                declined: config.declined
            ),
            viewFactory: self.environment.viewFactory
        )

        replacePresentedOfferIfPossible(with: alert)
    }
}

extension EngagementViewController {
    struct Environment {
        var viewFactory: ViewFactory
        var snackBar: SnackBar
    }
}
