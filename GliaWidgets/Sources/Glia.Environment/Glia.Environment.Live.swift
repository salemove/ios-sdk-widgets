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
        localFileThumbnailQueue: {
            let queue: FoundationBased.OperationQueue = .live()
            queue.setMaxConcurrentOperationCount(2)
            return queue
        }(),
        uiImage: .live,
        createFileDownload: FileDownload.init(with:storage:environment:),
        loadChatMessagesFromHistory: { true },
        timerProviding: .live,
        uiApplication: .live,
        createRootCoordinator: EngagementCoordinator.init(
            interactor:viewFactory:sceneProvider:engagementKind:features:environment:
        ),
        callVisualizerPresenter: .topViewController(application: .live)
    )
}

extension Glia.Environment.AudioSession {
    static let live = Self(overrideOutputAudioPort: AVAudioSession.sharedInstance().overrideOutputAudioPort(_:))
}
