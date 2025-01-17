import Foundation
import AVFoundation

extension Glia.Environment {
    static let live = Self(
        coreSdk: .live,
        audioSession: .live,
        uuid: UUID.init,
        date: Date.init,
        fileManager: .live,
        data: .live,
        gcd: .live,
        imageViewCache: .live,
        createThumbnailGenerator: { QuickLookBased.ThumbnailGenerator.live(.init()) },
        createFileDownload: FileDownload.init(with:storage:environment:),
        loadChatMessagesFromHistory: { true },
        timerProviding: .live,
        uiApplication: .live,
        uiScreen: .live,
        uiDevice: .live,
        notificationCenter: .live,
        createRootCoordinator: EngagementCoordinator.init(
            interactor:viewFactory:sceneProvider:engagementLaunching:screenShareHandler:features:environment:
        ),
        callVisualizerPresenter: .topViewController(application: .live),
        bundleManaging: .live,
        createFileUploader: FileUploader.init(maximumUploads:environment:),
        createFileUploadListModel: SecureConversations.FileUploadListViewModel.init,
        screenShareHandler: ScreenShareHandler.create(),
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.QueueScheduler.main,
        orientationManager: .init(environment: .init(
            uiApplication: .live,
            uiDevice: .live,
            notificationCenter: .live
        )),
        coreSDKConfigurator: .create(coreSdk: .live),
        proximityManager: .init(environment: .init(
            uiApplication: .live,
            uiDevice: .live
        )),
        print: .live,
        conditionalCompilation: .live,
        snackBar: .live,
        processInfo: .live,
        cameraDeviceManager: { try CoreSdkClient.live.getCameraDeviceManageable() },
        // This logic was moved here from EngagementCoordinator.Environment
        // Because it will be used for EntryWidget as well. This is as of now
        // The simplest way to determine if visitor is authenticated or not
        isAuthenticated: {
            do {
                return try CoreSdkClient.live.authentication(.forbiddenDuringEngagement).isAuthenticated
            } catch {
                debugPrint(#function, "isAuthenticated:", error.localizedDescription)
                return false
            }
        },
        dismissManager: .init { viewController, animated, completion in
            viewController.dismiss(animated: animated, completion: completion)
        },
        combineScheduler: .live
    )
}

extension Glia.Environment.AudioSession {
    static let live = Self(overrideOutputAudioPort: AVAudioSession.sharedInstance().overrideOutputAudioPort(_:))
}
