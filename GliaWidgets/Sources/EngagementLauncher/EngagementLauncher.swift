import Foundation

 /// `EngagementLauncher`class allows launching different types of engagements, such as chat,
 /// audio calls, video calls, and secure messaging.
public final class EngagementLauncher {
    typealias StartEngagementAction = (EngagementKind, AiScreenContext?, SceneProvider?) throws -> Void

    private var startEngagement: StartEngagementAction

    init(startEngagement: @escaping StartEngagementAction) {
        self.startEngagement = startEngagement
    }

    /// Starts a chat.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startChat(
        screenContext: AiScreenContext?,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try startEngagement(.chat, screenContext, sceneProvider)
    }

    /// Starts a audio call.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startAudioCall(
        screenContext: AiScreenContext?,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try startEngagement(.audioCall, screenContext, sceneProvider)
    }

    /// Starts a video call.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startVideoCall(
        screenContext: AiScreenContext?,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try startEngagement(.videoCall, screenContext, sceneProvider)
    }

    /// Starts a secure messaging.
    ///
    /// - Parameters:
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to
    ///     the first active foreground scene.
    public func startSecureMessaging(sceneProvider: SceneProvider? = nil) throws {
        try startEngagement(.messaging(.welcome), nil, sceneProvider)
    }
}

extension EngagementLauncher {
    func startSecureMessaging(initialScreen: SecureConversations.InitialScreen, sceneProvider: SceneProvider? = nil) throws {
        try startEngagement(.messaging(initialScreen), nil, sceneProvider)
    }
}
