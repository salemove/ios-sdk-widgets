#if DEBUG
extension ChatViewController {
    static func mock(chatViewModel: ChatViewModel = .mock()) -> ChatViewController {
        ChatViewController(
            viewModel: chatViewModel,
            viewFactory: .init(with: Theme())
        )
    }

    // MARK: - Empty Screen State
    static func mockEmptyScreen() -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        return .mock(chatViewModel: chatViewModel)
    }
}
#endif
