import UIKit

final class AlertCoordinator: UIViewControllerCoordinator {
    enum DelegateEvent {
        case dismiss
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let properties: AlertProperties
    private let viewFactory: ViewFactory

    init(
        properties: AlertProperties,
        viewFactory: ViewFactory
    ) {
        self.properties = properties
        self.viewFactory = viewFactory

        super.init()
    }

    override func start() -> Coordinated {
        let viewModel = AlertViewModel(
            properties: properties
        )

        let viewController = AlertViewController(
            viewModel: viewModel,
            viewFactory: viewFactory
        )

        viewModel.delegate = { [weak self] in
            switch $0 {
            case .dismiss:
                self?.delegate?(.dismiss)
            }
        }

        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve

        return viewController
    }
}
