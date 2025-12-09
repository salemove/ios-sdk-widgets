import UIKit

class EngagementViewController: UIViewController {
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
            case .showEndButton:
                view?.header.showEndButton()
            case .showCloseButton:
                view?.header.showCloseButton()
            case let .showLiveObservationConfirmation(link, accepted, declined):
                self.showLiveObservationConfirmation(
                    link: link,
                    accepted: accepted,
                    declined: declined
                )
            case let .showAlert(type):
                var placement: AlertPlacement = .root(self)
                // Need to show Engagement Ended dialog even over integrator's screens.
                if case .operatorEndedEngagement = type {
                    placement = .global
                }
                self.environment.alertManager.present(
                    in: placement,
                    as: type
                )
            case let .showSnackBarView(dismissTiming, style):
                showSnackBarView(dismissTiming: dismissTiming, style: style)
            case let .showNoConnectionSnackBarView(dismissTiming):
                showNoConnectionSnackBarView(dismissTiming: dismissTiming)
            }
        }
    }

    func showSnackBarView(
        dismissTiming: SnackBar.DismissTiming,
        style: Theme.SnackBarStyle
    ) {}

    func showNoConnectionSnackBarView(dismissTiming: SnackBar.DismissTiming) {}

    func swapAndBindEngagementViewModel(_ engagementModel: CommonEngagementModel) {
        self.viewModel = engagementModel
        bind(engagementViewModel: engagementModel)
    }

    private func showLiveObservationConfirmation(
        link: @escaping (WebViewController.Link) -> Void,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let config: LiveObservation.Confirmation = .init(
            link: link,
            accepted: accepted,
            declined: declined
        )
        switch viewModel.hasViewAppeared {
        case true: showLiveObservationConfirmationAlert(with: config)
        case false: pendingLiveObservationConfirmation = config
        }
    }

    private func showLiveObservationConfirmationAlert(with config: LiveObservation.Confirmation) {
        environment.alertManager.present(
            in: .root(self),
            as: .liveObservationConfirmation(
                link: config.link,
                accepted: config.accepted,
                declined: config.declined
            )
        )
    }
}
