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
        createThumbnailGenerator: { .mock },
        createFileDownload: { _, _, _ in .mock() },
        loadChatMessagesFromHistory: { true },
        timerProviding: .mock,
        uiApplication: .mock,
        uiScreen: .mock,
        uiDevice: .mock,
        notificationCenter: .mock,
        createRootCoordinator: EngagementCoordinator.mock,
        callVisualizerPresenter: .init { nil },
        bundleManaging: .init { .main },
        createFileUploader: FileUploader.mock,
        createFileUploadListModel: SecureConversations.FileUploadListViewModel.mock(environment:),
        screenShareHandler: .mock,
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        orientationManager: .mock(),
        coreSDKConfigurator: .mock,
        proximityManager: .mock,
        print: .mock,
        conditionalCompilation: .mock,
        snackBar: .mock,
        processInfo: .mock()
    )
}

extension Glia.Environment.AudioSession {
    static let mock = Self(overrideOutputAudioPort: { _ in })
}
#endif
