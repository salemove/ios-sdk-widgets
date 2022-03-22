import AVFoundation
import Foundation

extension Glia {
    struct Environment {
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
        var fromHistory: () -> Bool
        var timerProviding: FoundationBased.Timer.Providing
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
