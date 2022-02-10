@testable import GliaWidgets

extension Glia.Environment {
    static let failing = Self(
        coreSdk: .failing,
        chatStorage: .failing,
        audioSession: .failing,
        uuid: {
            fail("\(Self.self).uuid")
            return .mock
        }, date: {
            fail("\(Self.self).date")
            return .mock
        },
        fileManager: .failing,
        data: .failing,
        gcd: .failing,
        imageViewCache: .failing,
        localFileThumbnailQueue: .failing,
        uiImage: .failing,
        createFileDownload: { _, _, _ in .failing },
        fromHistory: {
            fail("\(Self.self).fromHistory")
            return true
        }
    )
}

extension Glia.Environment.AudioSession {
    static let failing = Self(
        overrideOutputAudioPort: { _ in
            fail("\(Self.self).overrideOutputAudioPort")
        }
    )
}

extension Glia.Environment.ChatStorage {
    static let failing = Self(
        databaseUrl: {
            fail("\(Self.self).databaseUrl")
            return nil

        },
        dropDatabase: {
            fail("\(Self.self).dropDatabase")
        },
        isEmpty: {
            fail("\(Self.self).isEmpty")
            return false
        },
        messages: { _ in
            fail("\(Self.self).messages")
            return []
        },
        updateMessage: { _ in
            fail("\(Self.self).updateMessage")
        },
        storeMessage: { _, _, _ in
            fail("\(Self.self).storeMessage")
        },
        storeMessages: { _, _, _ in
            fail("\(Self.self).storeMessages")
        },
        isNewMessage: { _ in
            fail("\(Self.self).isNewMessage")
            return true
        },
        newMessages: { _ in
            fail("\(Self.self).newMessages")
            return []
        }
    )
}
