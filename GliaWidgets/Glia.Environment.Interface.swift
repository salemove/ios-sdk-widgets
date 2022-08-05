import AVFoundation
import Foundation

extension Glia {
    /// `Environment` is a dependency container that solves the problem exchanging live dependencies to mocked ones during unit testing.
    /// So regarding particular naming of things like `var date: () -> Date` and `var uuid: () -> UUID` is a way of saying is that
    /// there is going to be used `Date()` and `UUID()` accordingly. In case of using some type that has several initializers that expect specific
    /// arguments, there will be used wrapper struct instead of simple closure, like `var data: FoundationBased.Data`for example.
    /// But the idea stays the same - for using 3rd party frameworks like `Core SDK` and 1st party like `Foundation.FileManager` we will have
    /// closures and structs-wrappers that mimic actual types provided by frameworks.
    /// Child `Environment` that is going to use `Foundation.Date` for some very specific case will get this type injected from parent `Environment`
    /// that may not use it explicitly (or use it for some very different case), so there's no sense to give to parent `Environment` property specific name,
    /// but very general one like var date: `() -> Date`.
    struct Environment {
        typealias CreateRootCoordinator = (
            _ interactor: Interactor,
            _ viewFactory: ViewFactory,
            _ sceneProvider: SceneProvider?,
            _ engagementKind: EngagementKind,
            _ features: Features,
            _ environment: RootCoordinator.Environment
        ) -> RootCoordinator
        var coreSdk: CoreSdkClient
        var chatStorage: ChatStorage
        var audioSession: AudioSession
        var uuid: () -> UUID
        var date: () -> Date
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
        var createRootCoordinator: CreateRootCoordinator
    }
}

extension Glia.Environment {
    func rootCoordinator(
        interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind,
        features: Features,
        environment: RootCoordinator.Environment
    ) -> RootCoordinator {
        self.createRootCoordinator(
            interactor,
            viewFactory,
            sceneProvider,
            engagementKind,
            features,
            environment
        )
    }
}

extension Glia.Environment {
    struct AudioSession {
        var overrideOutputAudioPort: (AVAudioSession.PortOverride) throws -> Void
    }
}

extension Glia.Environment {
    struct ChatStorage {
        var databaseUrl: () -> URL?
        var dropDatabase: () -> Void
        var isEmpty: () -> Bool

        var messages: (
            _ queueId: String
        ) -> [ChatMessage]

        var updateMessage: (
            _ message: ChatMessage
        ) -> Void

        var storeMessage: (
            _ message: CoreSdkClient.Message,
            _ queueId: String,
            _ operator: CoreSdkClient.Operator?
        ) -> Void

        var storeMessages: (
            _ messages: [CoreSdkClient.Message],
            _ queueId: String,
            _ operator: CoreSdkClient.Operator?
        ) -> Void

        var isNewMessage: (
            _ message: CoreSdkClient.Message
        ) -> Bool

        var newMessages: (
            _ messages: [CoreSdkClient.Message]
        ) -> [CoreSdkClient.Message]
    }
}
