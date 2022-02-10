@testable import GliaWidgets
import XCTest

extension Glia.Environment {
    static let failing = Self(
        coreSdk: .failing,
        fileManager: .failing,
        audioSession: .failing,
        uuid: {
            XCTFail("uuid")
            return .mock
        }
    )
}

extension Glia.Environment.FileManager {
    static let failing = Self(
        fileExistsAtPath: { _ in
            XCTFail("fileExistsAtPath")
            return false
        },
        removeItemAtURL: { _ in
            XCTFail("removeItemAtURL")
        }
    )
}

extension Glia.Environment.AudioSession {
    static let failing = Self(
        overrideOutputAudioPort: { _ in
            XCTFail("overrideOutputAudioPort")
        }
    )
}
