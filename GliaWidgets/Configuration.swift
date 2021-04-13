public enum Environment {
    case europe
    case usa
    case beta

    var url: String {
        switch self {
        case .europe:
            return "https://api.salemove.eu"
        case .usa:
            return "https://api.salemove.com"
        case .beta:
            return "https://api.beta.salemove.com/"
        }
    }
}

public struct Configuration {
    public let appToken: String
    public let apiToken: String
    public let environment: Environment
    public let site: String

    public init(appToken: String,
                apiToken: String,
                environment: Environment,
                site: String) {
        self.appToken = appToken
        self.apiToken = apiToken
        self.environment = environment
        self.site = site
    }
}
