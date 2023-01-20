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
            _ environment: EngagementCoordinator.Environment
        ) -> EngagementCoordinator
        var coreSdk: CoreSdkClient
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
        var callVisualizerPresenter: CallVisualizer.Presenter
        var bundleManaging: BundleManaging
        var createFileUploader: FileUploader.Create
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
    }
}

extension Glia.Environment {
    func rootCoordinator(
        interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind,
        features: Features,
        environment: EngagementCoordinator.Environment
    ) -> EngagementCoordinator {
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
