#if DEBUG
import Foundation

extension Glia.Environment {
    static let mock = Self(
        coreSdk: .mock,
        audioSession: .mock,
        uuid: { .mock },
        date: { .mock },
        fileManager: .mock,
        data: .mock,
        gcd: .mock,
        imageViewCache: .mock,
        localFileThumbnailQueue: .mock(),
        uiImage: .mock,
        createFileDownload: { _, _, _ in .mock() },
        loadChatMessagesFromHistory: { true },
        timerProviding: .mock,
        uiApplication: .mock,
        createRootCoordinator: EngagementCoordinator.mock,
        callVisualizerPresenter: .init { nil },
        bundleManaging: .init { .main },
        createFileUploader: FileUploader.mock,
        createFileUploadListModel: SecureConversations.FileUploadListViewModel.mock(environment:)
    )
}

extension Glia.Environment.AudioSession {
    static let mock = Self(overrideOutputAudioPort: { _ in })
}
#endif
