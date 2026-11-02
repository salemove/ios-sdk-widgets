import Foundation

extension Glia {
    struct ConfigurationFailure: Equatable {
        enum Level: Equatable {
            case warning
            case error
        }

        let name: String
        let level: Level

        var logMessage: String {
            "Glia Widgets SDK initialization failed: \(name)"
        }
    }
}

extension Glia.ConfigurationFailure {
    // Only fixed case or type names go into the log, never error descriptions,
    // which may contain URLs, credentials or other sensitive data.
    init(_ error: Error) {
        switch error {
        case let processError as CoreSdkClient.ConfigurationProcessError:
            self.init(processError)
        case let generalError as CoreSdkClient.GeneralError:
            self.init(generalError)
        case let configurationError as CoreSdkClient.ConfigurationError:
            self.init(configurationError)
        default:
            self.init(name: "\(type(of: error))", level: .error)
        }
    }

    private init(_ error: CoreSdkClient.ConfigurationProcessError) {
        switch error {
        case .siteSettingsRetrieval:
            self.init(name: "siteSettingsRetrieval", level: .warning)
        case .localeRetrieval:
            self.init(name: "localeRetrieval", level: .warning)
        case .emptyLocale:
            self.init(name: "emptyLocale", level: .warning)
        @unknown default:
            self.init(name: "ConfigurationProcessError", level: .error)
        }
    }

    private init(_ error: CoreSdkClient.GeneralError) {
        switch error {
        case .networkError:
            self.init(name: "networkError", level: .warning)
        case .internalError:
            self.init(name: "internalError", level: .error)
        @unknown default:
            self.init(name: "GeneralError(\(error.rawValue))", level: .error)
        }
    }

    private init(_ error: CoreSdkClient.ConfigurationError) {
        switch error {
        case .invalidSite:
            self.init(name: "invalidSite", level: .error)
        case .invalidEnvironment:
            self.init(name: "invalidEnvironment", level: .error)
        case .invalidRegionEndpoint:
            self.init(name: "invalidRegionEndpoint", level: .error)
        case .invalidConfiguration:
            self.init(name: "invalidConfiguration", level: .error)
        @unknown default:
            self.init(name: "ConfigurationError(\(error.rawValue))", level: .error)
        }
    }
}
