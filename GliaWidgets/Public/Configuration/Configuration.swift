import Foundation

/// Glia's engagement configuration.
public struct Configuration {
    /// Site authorization method
    public let authorizationMethod: AuthorizationMethod

    /// Environment
    public let environment: Environment

    /// Site
    public let site: String

    /// Visitor Context
    public let visitorContext: VisitorContext?

    /// Push notifications state. Pass `sandbox` to use push notifications during
    /// development/debug time, and `production` for release.
    public var pushNotifications: PushNotifications

    /// Company name. Appears during connection with operator.
    public let companyName: String

    /// The name of the manual locale override. If not set, or if set as `nil`,
    /// then the default locale from site settings will be used.
    public var manualLocaleOverride: String?

    /// If `true`, the SDK will not prompt the user for push notification
    /// permissions during authentication.
    public var suppressPushNotificationsPermissionRequestDuringAuthentication: Bool

    /// If `true`, the SDK will intercept the notification center delegate setup,
    /// set itself as the main delegate, and then proxy all events to the
    /// previously set delegate.
    public var isPushNotificationProxyEnabled: Bool

    /// Initializes the configuration.
    ///
    /// - Parameters:
    ///   - authorizationMethod: The site authorization method.
    ///   - environment: The environment to use.
    ///   - site: The site to use.
    ///   - visitorContext: Additional context about the visitor that operator may need.
    ///   - pushNotifications: Push notifications to use.
    ///   - companyName: Name of the company.
    ///   - manualLocaleOverride: The name of the manual locale override. If not set, 
    ///   or if set as `nil`, then the default locale from site settings will be used.
    ///   - suppressPushNotificationsPermissionRequestDuringAuthentication: If `true`, the SDK will not prompt the user for push
    /// notification permissions during authentication.
    ///
    public init(
        authorizationMethod: AuthorizationMethod,
        environment: Environment,
        site: String,
        visitorContext: VisitorContext? = nil,
        pushNotifications: PushNotifications = .disabled,
        companyName: String = "",
        manualLocaleOverride: String? = nil,
        suppressPushNotificationsPermissionRequestDuringAuthentication: Bool = false,
        isPushNotificationProxyEnabled: Bool = true
    ) {
        self.authorizationMethod = authorizationMethod
        self.environment = environment
        self.site = site
        self.visitorContext = visitorContext
        self.pushNotifications = pushNotifications
        self.companyName = companyName
        self.manualLocaleOverride = manualLocaleOverride
        self.suppressPushNotificationsPermissionRequestDuringAuthentication = suppressPushNotificationsPermissionRequestDuringAuthentication
        self.isPushNotificationProxyEnabled = isPushNotificationProxyEnabled
    }
}

public extension Configuration {
    /// Site authorization method.
    enum AuthorizationMethod {
        /// Site API key authorization.
        @available(*, deprecated, message: "Use .userApiKey(id:secret:) instead.")
        case siteApiKey(id: String, secret: String)

        /// User API key authorization.
        case userApiKey(id: String, secret: String)

        var coreAuthorizationMethod: CoreSdkClient.AuthorizationMethod {
            switch self {
            case .siteApiKey(let id, let secret):
                return .siteApiKey(id: id, secret: secret)
            case let .userApiKey(id, secret):
                return .userApiKey(id: id, secret: secret)
            }
        }

        var id: String {
            switch self {
            case let .siteApiKey(id, _):
                return id
            case let .userApiKey(id, _):
                return id
            }
        }

        var secret: String {
            switch self {
            case let .siteApiKey(_, secret):
                return secret
            case let .userApiKey(_, secret):
                return secret
            }
        }
    }
}

extension Configuration {
    /// Additional context about the visitor that operator may need.
    public struct VisitorContext {
        /// Asset ID represented by UUID from Glia Hub.
        public let assetId: UUID

        ///
        /// - Parameter assetId: Asset ID represented by UUID from Glia Hub.
        public init(assetId: UUID) {
            self.assetId = assetId
        }
    }
}

extension Configuration {
    /// Represents the configuration options for push notifications within the SDK.
    public enum PushNotifications {
        /// Push notifications are disabled.
        case disabled

        /// Push notifications are configured for sandbox environment. Suitable for testing.
        case sandbox

        /// Push notifications are configured for production environment.
        case production

        var coreSdk: CoreSdkClient.Configuration.PushNotifications {
            switch self {
            case .disabled:
                return .disabled
            case .sandbox:
                return .sandbox
            case .production:
                return .production
            }
        }
    }
}
