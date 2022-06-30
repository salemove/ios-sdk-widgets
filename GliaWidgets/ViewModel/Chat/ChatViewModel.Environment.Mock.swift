#if DEBUG
extension ChatViewModel.Environment {
    static let mock = Self(
        chatStorage: .mock,
        fetchFile: { _, _, _ in },
        sendSelectedOptionValue: { _, _ in },
        uploadFileToEngagement: { _, _, _ in },
        fileManager: .mock,
        data: .mock,
        date: { .mock },
        gcd: .mock,
        localFileThumbnailQueue: .mock(),
        uiImage: .mock,
        createFileDownload: { file, fileStorage, env in
                .mock(
                    file: file,
                    storage: fileStorage,
                    environment: env
                )
        },
        fromHistory: { true },
        fetchSiteConfigurations: { _ in },
        getCurrentEngagement: { return nil },
        timerProviding: .mock,
        uuid: { UUID.mock },
        uiApplication: .mock
    )
}
#endif
