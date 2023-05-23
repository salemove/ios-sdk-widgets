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
    /// Controls the visibility of the "Powered by" text and image.
    public let isWhiteLabelApp: Bool
    /// Company name. Appears during connection with operator.
    public let companyName: String
    /// Initializes the configuration.
    ///
    /// - Parameters:
    ///   - authorizationMethod: The site authorization method.
    ///   - environment: The environment to use.
    ///   - site: The site to use.
    ///   - visitorContext: Additional context about the visitor that operator may need.
    ///
    public init(
        authorizationMethod: AuthorizationMethod,
        environment: Environment,
        site: String,
        visitorContext: VisitorContext? = nil,
        pushNotifications: PushNotifications = .disabled,
        isWhiteLabelApp: Bool = false,
        companyName: String = L10n.Chat.Connect.Queue.firstText
    ) {
        self.authorizationMethod = authorizationMethod
        self.environment = environment
        self.site = site
        self.visitorContext = visitorContext
        self.pushNotifications = pushNotifications
        self.isWhiteLabelApp = isWhiteLabelApp
        self.companyName = companyName
    }
}

public extension Configuration {
    /// Site authorization method.
    enum AuthorizationMethod {
        /// Site API key authorization.
        case siteApiKey(id: String, secret: String)

        var coreAuthorizationMethod: CoreSdkClient.Salemove.AuthorizationMethod {
            switch self {
            case .siteApiKey(let id, let secret):
                return .siteApiKey(id: id, secret: secret)
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
    public enum PushNotifications {
        case disabled, sandbox, production

        var coreSdk: CoreSdkClient.Salemove.Configuration.PushNotifications {
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
