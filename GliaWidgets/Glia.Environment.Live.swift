import Foundation
import AVFoundation

extension Glia.Environment {
    static let live = Self(
        coreSdk: .live,
        chatStorage: .live,
        audioSession: .live,
        uuid: UUID.init
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
        let fileManager = FileManager.default

        let chatStorage = ChatStorage(dbUrl: dbUrl)

        return .init(
            databaseUrl: { dbUrl },
            dropDatabase: {

                guard
                    let dbUrl = dbUrl,
                    fileManager.fileExists(atPath: dbUrl.standardizedFileURL.path)
                else { return }

                do {
                    try fileManager.removeItem(at: dbUrl)
                } catch {
                    print("DB has not been removed due to: '\(error)'.")
                }
            },
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
