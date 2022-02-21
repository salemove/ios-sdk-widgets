#if DEBUG
extension ChatViewModel.Environment {
    static let mock = Self(
        chatStorage: .mock,
        fetchFile: { _, _, _ in },
        sendSelectedOptionValue: { _, _ in },
        uploadFileToEngagement: { _, _, _ in },
        fileManager: .mock,
        data: .mock,
        date: { .mock }
    )
}
#endif
