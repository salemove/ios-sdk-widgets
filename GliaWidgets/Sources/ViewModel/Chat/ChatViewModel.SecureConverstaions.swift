extension ChatViewModel {
    func migrate(from transcript: SecureConversations.TranscriptModel) {
        sections = transcript.sections
        isViewLoaded = transcript.isViewLoaded
        // Keep state of view-model in sync with Interactor.
        interactorEvent(.stateChanged(interactor.state))
        action?(.scrollToBottom(animated: true))
        // Set view active, to avoid unread message button
        // to be shown.
        isViewActive.value = true
    }
}
