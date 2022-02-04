import AVFoundation
import Foundation

extension Glia {
    struct Environment {
        var coreSdk: CoreSdkClient
        var fileManager: FileManager
        var audioSession: AudioSession
        var uuid: () -> UUID
    }
}

extension Glia.Environment {
    struct FileManager {
        var fileExistsAtPath: (String) -> Bool
        var removeItemAtURL: (URL) throws -> Void
    }

    struct AudioSession {
        var overrideOutputAudioPort: (AVAudioSession.PortOverride) throws -> Void
    }
}
