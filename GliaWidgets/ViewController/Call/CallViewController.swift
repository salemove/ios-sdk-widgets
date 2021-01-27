import UIKit

class CallViewController: EngagementViewController, MediaUpgradePresenter {
    private let viewModel: CallViewModel

    init(viewModel: CallViewModel,
         viewFactory: ViewFactory) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, viewFactory: viewFactory)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        let view = viewFactory.makeCallView()
        self.view = view
        bind(viewModel: viewModel, to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.viewDidLoad)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return viewFactory.theme.call.preferredStatusBarStyle }

    private func bind(viewModel: CallViewModel, to view: CallView) {
        view.chatTapped = { viewModel.event(.chatTapped) }

        viewModel.action = { action in
            switch action {
            case .queue:
                view.setConnecState(.queue, animated: false)
            case .connecting(name: let name, imageUrl: let imageUrl):
                view.setConnecState(.connecting(name: name, imageUrl: imageUrl), animated: true)
            case .hideConnect:
                view.setConnecState(.none, animated: true)
            case .setTitle(let title):
                view.header.title = title
            case .setOperatorName(let name):
                view.operatorNameLabel.text = name
            case .setOperatorImage(url: let url):
                view.operatorImageView.setImage(from: url, animated: true)
            case .setDuration(let duration):
                view.durationLabel.text = duration
            }
        }
    }
}
