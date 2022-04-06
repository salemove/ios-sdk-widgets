import Foundation
import AVFoundation

extension Glia.Environment {
    static let live = Self(
        coreSdk: .live,
        chatStorage: .live,
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
        fromHistory: { true },
        timerProviding: .live
    )
}

extension Glia.Environment.AudioSession {
    static let live = Self(overrideOutputAudioPort: AVAudioSession.sharedInstance().overrideOutputAudioPort(_:))
}

extension Glia.Environment.ChatStorage {
    static let live: Self = {
        let dbName = "GliaChat.sqlite"
        let dbUrl = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(dbName)

        let chatStorage = ChatStorage(dbUrl: dbUrl)

        return .init(
            databaseUrl: { dbUrl },
            dropDatabase: chatStorage.dropDatabase,
            isEmpty: chatStorage.isEmpty,
            messages: chatStorage.messages,
            updateMessage: chatStorage.updateMessage,
            storeMessage: chatStorage.storeMessage,
            storeMessages: chatStorage.storeMessages,
            isNewMessage: chatStorage.isNewMessage,
            newMessages: chatStorage.newMessages
        )
    }()
}
