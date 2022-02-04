extension Glia.Environment {
    static let mock = Self(
        coreSdk: .mock,
        fileManager: .mock,
        audioSession: .mock,
        uuid: { .mock }
    )
}

extension Glia.Environment.FileManager {
    static let mock = Self(
        fileExistsAtPath: { _ in false },
        removeItemAtURL: { _ in }
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
