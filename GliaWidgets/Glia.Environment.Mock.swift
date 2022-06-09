#if DEBUG
import Foundation

extension Glia.Environment {
    static let mock = Self(
        coreSdk: .mock,
        chatStorage: .mock,
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
        fromHistory: { true },
        timerProviding: .mock,
        uiApplication: .mock
    )
}

extension Glia.Environment.AudioSession {
    static let mock = Self(overrideOutputAudioPort: { _ in })
}

extension Glia.Environment.ChatStorage {
    static let mock = Self(
        databaseUrl: { nil },
        dropDatabase: {},
        isEmpty: { false },
        messages: { _ in return [] },
        updateMessage: { _ in },
        storeMessage: { _, _, _ in },
        storeMessages: { _, _, _ in },
        isNewMessage: { _ in return true },
        newMessages: { _ in return [] }
    )
}
#endif
