final class ChatViewController: ViewController {
    private let viewModel: ChatViewModel
    private let viewFactory: ViewFactory

    init(viewModel: ChatViewModel, viewFactory: ViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let view = viewFactory.makeChatView()
        self.view = view
        bind(viewModel: viewModel, to: view)
    }

    private func bind(viewModel: ChatViewModel, to view: ChatView) {}
}
