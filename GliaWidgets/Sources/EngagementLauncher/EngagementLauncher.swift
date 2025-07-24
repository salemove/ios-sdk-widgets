import Foundation

 /// `EngagementLauncher`class allows launching different types of engagements, such as chat,
 /// audio calls, video calls, and secure messaging.
public final class EngagementLauncher {
    typealias StartEngagementAction = (EngagementKind, @escaping ((AiScreenContext?) -> Void) -> Void, SceneProvider?) throws -> Void

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
        screenContext: @escaping ((AiScreenContext?) -> Void) -> Void,
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
        screenContext: @escaping ((AiScreenContext?) -> Void) -> Void,
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
        screenContext: @escaping ((AiScreenContext?) -> Void) -> Void,
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
        try startEngagement(.messaging(.welcome), { $0(nil) }, sceneProvider)
    }
}

extension EngagementLauncher {
    func startSecureMessaging(initialScreen: SecureConversations.InitialScreen, sceneProvider: SceneProvider? = nil) throws {
        try startEngagement(.messaging(initialScreen), { $0(nil) }, sceneProvider)
    }
}
