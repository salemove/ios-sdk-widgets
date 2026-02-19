import Foundation
import GliaWidgets

extension Configuration {
    static func empty(with env: Environment = .beta) -> Self {
        .init(
            authorizationMethod: .userApiKey(id: "", secret: ""),
            environment: env,
            site: "",
            pushNotifications: .disabled,
            manualLocaleOverride: nil,
            suppressPushNotificationsPermissionRequestDuringAuthentication: false
        )
    }

    init?(queryItems: [URLQueryItem]) {
        guard
            let siteId = Self.queryValue(
                in: queryItems,
                namedAnyOf: ["site_id"]
            ),
            let apiKeyId = Self.queryValue(
                in: queryItems,
                namedAnyOf: ["api_key_id"]
            ),
            let apiKeySecret = Self.queryValue(
                in: queryItems,
                namedAnyOf: ["api_key_secret"]
            ),
            let envName = Self.queryValue(
                in: queryItems,
                namedAnyOf: ["env"]
            ),
            let environment = Environment(rawValue: envName)
        else {
            return nil
        }

        let authorizationMethod = Self.queryAuthorizationMethod(
            id: apiKeyId,
            secret: apiKeySecret
        )

        let visitorAssetId = queryItems.first { $0.name == "visitor_context_asset_id" }?.value ?? ""
        let visitorContext = UUID(uuidString: visitorAssetId)
            .map(Configuration.VisitorContext.init(assetId:))
        let manualLocaleOverride = queryItems.first { $0.name == "manual_locale_override" }?.value ?? nil

        self = .init(
            authorizationMethod: authorizationMethod,
            environment: environment,
            site: siteId,
            visitorContext: visitorContext,
            pushNotifications: .disabled,
            manualLocaleOverride: manualLocaleOverride,
            suppressPushNotificationsPermissionRequestDuringAuthentication: false
        )
    }
}

private extension Configuration {
    static func queryValue(
        in queryItems: [URLQueryItem],
        namedAnyOf keys: [String]
    ) -> String? {
        for key in keys {
            if let value = queryItems.first(
                where: { $0.name.caseInsensitiveCompare(key) == .orderedSame }
            )?.value {
                return value
            }
        }
        return nil
    }

    static func queryAuthorizationMethod(
        id: String,
        secret: String
    ) -> AuthorizationMethod {
        // API key secret prefixes:
        // - gls_ => site API key
        // - everything else => user API key
        if secret.lowercased().hasPrefix("gls_") {
            return .siteApiKey(id: id, secret: secret)
        } else {
            return .userApiKey(id: id, secret: secret)
        }
    }
}

private extension Environment {
    init?(rawValue: String) {
        switch rawValue {
        case "beta":
            self = .beta
        case "us":
            self = .usa
        case "eu":
            self = .europe
        default:
            guard let url = URL(string: rawValue) else { return nil }
            self = .custom(url)
        }
    }
}

extension Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case authorizationMethod,
             environment,
             site,
             visitorContext,
             pushNotifications,
             manualLocaleOverride,
             suppressPushNotificationsPermissionRequestDuringAuthentication
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = try .init(
            authorizationMethod: container.decode(Configuration.AuthorizationMethod.self, forKey: .authorizationMethod),
            environment: container.decode(Environment.self, forKey: .environment),
            site: container.decode(String.self, forKey: .site),
            visitorContext: container.decodeIfPresent(VisitorContext.self, forKey: .visitorContext),
            pushNotifications: container.decodeIfPresent(PushNotifications.self, forKey: .pushNotifications) ?? .disabled,
            manualLocaleOverride: container.decodeIfPresent(String.self, forKey: .manualLocaleOverride) ?? nil,
            suppressPushNotificationsPermissionRequestDuringAuthentication: container
                .decodeIfPresent(
                    Bool.self,
                    forKey: .suppressPushNotificationsPermissionRequestDuringAuthentication
                ) ?? false
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authorizationMethod, forKey: .authorizationMethod)
        try container.encode(environment, forKey: .environment)
        try container.encode(site, forKey: .site)
        try container.encode(visitorContext, forKey: .visitorContext)
        try container.encode(pushNotifications, forKey: .pushNotifications)
        try container.encode(manualLocaleOverride, forKey: .manualLocaleOverride)
        try container.encode(
            suppressPushNotificationsPermissionRequestDuringAuthentication,
            forKey: .suppressPushNotificationsPermissionRequestDuringAuthentication
        )
    }
}

extension Configuration.AuthorizationMethod: Codable {
    enum CodingKeys: String, CodingKey {
        case type, id, secret
    }

    private enum AuthorizationType: String, Codable {
        case siteApiKey
        case userApiKey
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(AuthorizationType.self, forKey: .type) ?? .siteApiKey
        let id = try container.decode(String.self, forKey: .id)
        let secret = try container.decode(String.self, forKey: .secret)

        switch type {
        case .siteApiKey:
            self = .siteApiKey(id: id, secret: secret)
        case .userApiKey:
            self = .userApiKey(id: id, secret: secret)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .siteApiKey(id, secret):
            try container.encode(AuthorizationType.siteApiKey, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(secret, forKey: .secret)
        case let .userApiKey(id, secret):
            try container.encode(AuthorizationType.userApiKey, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(secret, forKey: .secret)
        @unknown default:
            debugPrint("💥 Can't encode AuthorizationMethod: \(self)")
        }
    }
}

extension Environment: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "beta":
            self = .beta
        case "us":
            self = .usa
        case "eu":
            self = .europe
        default:
            guard let custom = URL(string: rawValue) else {
                throw NSError(domain: "not-valid-env", code: 0)
            }
            self = .custom(custom)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .europe:
            try container.encode("eu")
        case .usa:
            try container.encode("us")
        case .beta:
            try container.encode("beta")
        case .custom(let url):
            try container.encode(url.absoluteString)
        @unknown default:
            debugPrint("💥 Can't encode Environment: \(self)")
        }
    }
}

extension Configuration.VisitorContext: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try .init(assetId: container.decode(UUID.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(assetId)
    }
}

extension Configuration.PushNotifications: RawRepresentable, Codable {
    public var rawValue: String {
        switch self {
        case .disabled:
            return "disabled"
        case .sandbox:
            return "sandbox"
        case .production:
            return "production"
        @unknown default:
            return ""
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "disabled":
            self = .disabled
        case "sandbox":
            self = .sandbox
        case "production":
            self = .production
        default:
            return nil
        }
    }
}
