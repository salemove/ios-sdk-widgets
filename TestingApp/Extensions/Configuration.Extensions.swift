import Foundation
import GliaWidgets

extension Configuration {
    static func empty(with env: Environment = .beta) -> Self {
        .init(
            authorizationMethod: .siteApiKey(id: "", secret: ""),
            environment: env,
            site: ""
        )
    }
}

extension Configuration {
    init?(queryItems: [URLQueryItem]) {
        guard
            let siteId = queryItems.first(where: { $0.name == "site_id"})?.value,
            let siteApiKeyId = queryItems.first(where: { $0.name == "api_key_id"})?.value,
            let siteApiKeySecret = queryItems.first(where: { $0.name == "api_key_secret"})?.value,
            let envName = queryItems.first(where: { $0.name == "env"})?.value
        else {
            return nil
        }

        let visitorAssetId = queryItems.first(where: { $0.name == "visitor_context_asset_id" })?.value ?? ""
        let visitorContext = UUID(uuidString: visitorAssetId)
            .map(Configuration.VisitorContext.init(assetId:))

        self = .init(
            authorizationMethod: .siteApiKey(id: siteApiKeyId, secret: siteApiKeySecret),
            environment: .init(rawValue: envName) ?? .beta,
            site: siteId,
            visitorContext: visitorContext
        )
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
        case authorizationMethod, environment, site, visitorContext
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = try .init(
            authorizationMethod: container.decode(Configuration.AuthorizationMethod.self, forKey: .authorizationMethod),
            environment: container.decode(Environment.self, forKey: .environment),
            site: container.decode(String.self, forKey: .site),
            visitorContext: container.decodeIfPresent(VisitorContext.self, forKey: .visitorContext)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authorizationMethod, forKey: .authorizationMethod)
        try container.encode(environment, forKey: .environment)
        try container.encode(site, forKey: .site)
        try container.encode(visitorContext, forKey: .visitorContext)
    }
}

extension Configuration.AuthorizationMethod: Codable {

    enum CodingKeys: String, CodingKey {
        case id, secret, appToken
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.appToken) {
            self = try .appToken(container.decode(String.self, forKey: .appToken))
        } else {
            self = try .siteApiKey(
                id: container.decode(String.self, forKey: .id),
                secret: container.decode(String.self, forKey: .secret)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .appToken(let appToken):
            try container.encode(appToken, forKey: .appToken)
        case let .siteApiKey(id, secret):
            try container.encode(id, forKey: .id)
            try container.encode(secret, forKey: .secret)
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
                throw NSError(domain: "not-valid-env", code: -33)
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
