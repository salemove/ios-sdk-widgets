import UIKit

class EngagementViewController: ViewController {
    internal let viewFactory: ViewFactory
    private let viewModel: EngagementViewModel

    init(viewModel: EngagementViewModel, viewFactory: ViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.event(.viewWillAppear)
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

    private func bind(viewModel: EngagementViewModel, to view: EngagementView) {
        view.header.endButton.tap = { [weak self] in self?.viewModel.event(.closeTapped) }
        view.header.endScreenShareButton.tap = { [weak self] in self?.viewModel.event(.endScreenSharingTapped) }
        view.header.backButton.tap = { [weak self] in self?.viewModel.event(.backTapped) }
        view.header.closeButton.tap = { [weak self] in self?.viewModel.event(.closeTapped) }

        viewModel.engagementAction = { action in
            switch action {
            case .showEndButton:
                view.header.showEndButton()

            case .showEndScreenShareButton:
                view.header.showEndScreenSharingButton()
            }
        }
    }
}
