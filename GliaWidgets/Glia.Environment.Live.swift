import Foundation
import AVFoundation

extension Glia.Environment {
    static let live = Self(
        coreSdk: .live,
        fileManager: .live,
        audioSession: .live,
        uuid: UUID.init
    )
}

extension Glia.Environment.FileManager {
    static let live = Self(
        fileExistsAtPath: Foundation.FileManager.default.fileExists(atPath:),
        removeItemAtURL: Foundation.FileManager.default.removeItem(at:)
    )
}

extension Glia.Environment.AudioSession {
    static let live = Self(overrideOutputAudioPort: AVAudioSession.sharedInstance().overrideOutputAudioPort(_:))
}
