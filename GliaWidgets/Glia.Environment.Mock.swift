extension Glia.Environment {
    static let mock = Self(
        coreSdk: .mock,
        chatStorage: .mock,
        audioSession: .mock,
        uuid: { .mock }
    )
}

extension Glia.Environment.AudioSession {
    static let mock = Self(overrideOutputAudioPort: { _ in })
}

extension UUID {
    static let mock = Self(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef").unsafelyUnwrapped
}

extension URL {
    static let mock = Self(string: "https://mock.mock").unsafelyUnwrapped
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
