import Foundation
import GliaCoreSDK

 /// `EngagementLauncher`class allows launching different types of engagements, such as chat,
 /// audio calls, video calls, and secure messaging.
public final class EngagementLauncher {
    private let queueIds: [String]?

    public init(queueIds: [String]?) {
        self.queueIds = queueIds
    }

    /// Starts a chat.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startChat(sceneProvider: SceneProvider? = nil) {
        startEngagement(of: .chat, sceneProvider: sceneProvider)
    }

    /// Starts a audio call.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startAudioCall(sceneProvider: SceneProvider? = nil) {
        startEngagement(of: .audioCall, sceneProvider: sceneProvider)
    }

    /// Starts a video call.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startVideoCall(sceneProvider: SceneProvider? = nil) {
        startEngagement(of: .videoCall, sceneProvider: sceneProvider)
    }

    /// Starts a secure messaging.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startSecureMessaging(sceneProvider: SceneProvider? = nil) {
        startEngagement(of: .messaging(.welcome), sceneProvider: sceneProvider)
    }

    private func startEngagement(
        of engagementKind: EngagementKind,
        sceneProvider: SceneProvider?
    ) {}
}
