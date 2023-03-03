extension ChatViewModel {
    func migrate(from transcript: SecureConversations.TranscriptModel) {
        sections = transcript.sections
        isViewLoaded = transcript.isViewLoaded
        enqueue(mediaType: .text)
        // Set view active, to avoid unread message button
        // to be shown.
        isViewActive.value = true
    }
}
