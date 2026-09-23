import UIKit
@_spi(GliaWidgets) internal import GliaCoreSDK

/// The push notification categories that the SDK can subscribe to.
public enum PushNotificationsType: Int {
    /// An engagement started.
    case start

    /// An engagement ended.
    case end

    /// An engagement failed.
    case failed

    /// A new message was received.
    case message

    /// An engagement was transferred.
    case transfer
}

/// The context represented by a handled push notification.
public enum PushType: RawRepresentable, Equatable, Codable {
    /// A push type that is not recognized by this SDK version.
    case unidentified(String)

    /// A message in a live chat engagement.
    case chatMessage

    /// A message in a secure conversation.
    case queueMessage

    /// Creates a push type from its server value.
    /// - Parameter rawValue: The server value representing the push type.
    public init?(rawValue: String) {
        switch rawValue {
        case "engagement.chat.message":
            self = .chatMessage
        case "queued_message.created":
            self = .queueMessage
        default:
            self = .unidentified(rawValue)
        }
    }

    /// The server value representing the push type.
    public var rawValue: String {
        switch self {
        case let .unidentified(value):
            return value
        case .chatMessage:
            return "engagement.chat.message"
        case .queueMessage:
            return "queued_message.created"
        }
    }

    /// Creates a push type by decoding its server value.
    /// - Parameter decoder: The decoder containing the push type value.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .unidentified(rawValue)
    }

    /// Encodes the push type using its server value.
    /// - Parameter encoder: The encoder that receives the push type value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Indicates whether a push notification was handled while the app was active or in the background.
public enum PushTiming: Int, Codable {
    /// The push notification arrived while the visitor was using the app.
    case inApp

    /// The push notification arrived while the app was in the background.
    case background

    /// The push notification timing is not recognized by this SDK version.
    case unidentified
}

/// A push notification action handled by the Widgets SDK.
public struct Push: Codable, Equatable {
    private enum CodingKeys: CodingKey {
        case actionIdentifier, type, timing, visitorId
    }

    /// The action identifier supplied by `UNNotificationResponse`.
    public let actionIdentifier: String

    /// The context represented by the notification.
    public let type: PushType

    /// Whether the notification was handled in the app or from the background.
    public let timing: PushTiming

    /// The visitor associated with the notification, when available.
    public let visitorId: String?

    /// Creates a push notification action.
    /// - Parameters:
    ///   - actionIdentifier: The action identifier supplied by `UNNotificationResponse`.
    ///   - type: The context represented by the notification.
    ///   - timing: Whether the notification was handled in the app or from the background.
    ///   - visitorId: The visitor associated with the notification, when available.
    public init(
        actionIdentifier: String,
        type: PushType,
        timing: PushTiming,
        visitorId: String?
    ) {
        self.actionIdentifier = actionIdentifier
        self.type = type
        self.timing = timing
        self.visitorId = visitorId
    }

    /// Creates a push action by decoding its server representation.
    /// - Parameter decoder: The decoder containing the push action.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actionIdentifier = try container.decode(String.self, forKey: .actionIdentifier)

        let pushTypeRawValue = try container.decode(String.self, forKey: .type)
        type = PushType(rawValue: pushTypeRawValue) ?? .unidentified(pushTypeRawValue)

        timing = (try? container.decode(PushTiming.self, forKey: .timing)) ?? .unidentified
        visitorId = try container.decodeIfPresent(String.self, forKey: .visitorId)
    }

    /// Encodes the push action using its server representation.
    /// - Parameter encoder: The encoder that receives the push action.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actionIdentifier, forKey: .actionIdentifier)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(timing, forKey: .timing)
        try container.encodeIfPresent(visitorId, forKey: .visitorId)
    }

    /// Returns whether two push actions represent the same handled action.
    public static func == (lhs: Push, rhs: Push) -> Bool {
        lhs.type == rhs.type && lhs.actionIdentifier == rhs.actionIdentifier
    }
}

/// A closure invoked when the SDK handles a push notification action.
public typealias PushActionBlock = (Push) -> Void

extension PushNotificationsType {
    var coreType: GliaCoreSDK.PushNotificationsType {
        switch self {
        case .start: return .start
        case .end: return .end
        case .failed: return .failed
        case .message: return .message
        case .transfer: return .transfer
        }
    }
}

extension Push {
    init(corePush: GliaCoreSDK.Push) {
        self.init(
            actionIdentifier: corePush.actionIdentifier,
            type: .init(coreType: corePush.type),
            timing: .init(coreTiming: corePush.timing),
            visitorId: corePush.visitorId
        )
    }
}

private extension PushType {
    init(coreType: GliaCoreSDK.PushType) {
        switch coreType {
        case .chatMessage:
            self = .chatMessage
        case .queueMessage:
            self = .queueMessage
        case let .unidentified(value):
            self = .unidentified(value)
        @unknown default:
            self = .unidentified(coreType.rawValue)
        }
    }
}

private extension PushTiming {
    init(coreTiming: GliaCoreSDK.PushTiming) {
        switch coreTiming {
        case .inApp:
            self = .inApp
        case .background:
            self = .background
        case .unidentified:
            self = .unidentified
        @unknown default:
            self = .unidentified
        }
    }
}

public struct PushNotifications {
    let environment: Environment

    /// Notifies the push notifications system that the application has successfully registered for remote notifications.
    ///
    /// This method is usually called from the `UIApplicationDelegate`'s registration success callback.
    ///
    /// - Parameters:
    ///   - application: The application instance that registered for notifications.
    ///   - deviceToken: The device token received from APNs.
    ///
    public func applicationDidRegisterForRemoteNotificationsWithDeviceToken(
        application: UIApplication,
        deviceToken: Data
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "applicationDidRegisterForRemoteNotificationsWithDeviceToken",
            methodParams: ["application", "deviceToken"]
        )
        environment.coreSdk.pushNotifications.applicationDidRegisterForRemoteNotificationsWithDeviceToken(
            application,
            deviceToken
        )
    }

    /// Notifies the push notifications system that the application failed to register for remote notifications.
    ///
    /// This method is typically called from the `UIApplicationDelegate`'s failure callback.
    ///
    /// - Parameters:
    ///   - application: The application instance that attempted registration.
    ///   - error: The error encountered during the registration process.
    ///
    public func applicationDidFailToRegisterForRemoteNotificationsWithError(
        application: UIApplication,
        error: any Error
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "applicationDidFailToRegisterForRemoteNotificationsWithError",
            methodParams: ["application", "error"]
        )
        environment.coreSdk.pushNotifications.applicationDidFailToRegisterForRemoteNotificationsWithError(
            application,
            error
        )
    }

    /// Forwards the notification delivery event to the underlying SDK when a notification is about to be presented.
    ///
    /// This method should be called from `UNUserNotificationCenterDelegate`'s
    /// `userNotificationCenter(_:willPresent:withCompletionHandler:)` method.
    ///
    /// - Parameters:
    ///   - center: The `UNUserNotificationCenter` instance handling the notification.
    ///   - willPresentNotificationCenter: The `UNNotification` to be presented.
    ///   - completionHandler: A closure that takes the presentation options for the notification.
    ///
    public func userNotificationCenterWillPresent(
        center: UNUserNotificationCenter,
        willPresent: UNNotification,
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "userNotificationCenterWillPresent",
            methodParams: ["center", "willPresent", "completionHandler"]
        )
        environment.coreSdk.pushNotifications.userNotificationCenterWillPresent(
            center,
            willPresent,
            completionHandler
        )
    }

    /// Forwards the user's response for a delivered notification to the underlying SDK.
    ///
    /// This method should be invoked from `UNUserNotificationCenterDelegate`'s
    /// `userNotificationCenter(_:didReceive:withCompletionHandler:)` method.
    ///
    /// - Parameters:
    ///   - center: The `UNUserNotificationCenter` instance that handled the response.
    ///   - didReceiveResponseCenter: The `UNNotificationResponse` received from the user.
    ///   - completionHandler: A closure executed once the response has been handled.
    ///
    public func userNotificationCenterDidReceiveResponse(
        center: UNUserNotificationCenter,
        didReceive: UNNotificationResponse,
        completionHandler: @escaping () -> Void
    ) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "userNotificationCenterDidReceiveResponse",
            methodParams: ["center", "didReceive", "completionHandler"]
        )
        environment.coreSdk.pushNotifications.userNotificationCenterDidReceiveResponse(
            center,
            didReceive,
            completionHandler
        )
    }

    /// Sets the current push action handler that the SDK uses to forward notification actions.
    ///
    /// This handler is executed in response to user interactions with notifications (via
    /// `UNNotificationResponse.actionIdentifier`).
    ///
    /// - Parameter handler: An optional `PushActionBlock` closure used as a callback for push actions.
    ///
    public func setPushHandler(_ handler: PushActionBlock?) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "setPushHandler",
            methodParams: ["handler"]
        )
        environment.coreSdk.pushNotifications.setPushHandler(handler)
    }

    /// Subscribe to specific push notifications type.
    ///
    /// - Parameters:
    ///   - types: array of PushnotificationType
    ///
    public func subscribeTo(_ types: [PushNotificationsType]) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "subscribeTo",
            methodParams: ["types"]
        )
        environment.coreSdk.pushNotifications.subscribeTo(types)
    }
}
