import Foundation

enum StringProvidingPhase {
    case notConfigured
    case configured((String) -> String?)

    var getRemoteString: ((String) -> String?)? {
        switch self {
        case .notConfigured:
            return nil
        case let .configured(stringProviding):
            return stringProviding
        }
    }

    func callAsFunction(_ key: String) -> String? {
        getRemoteString?(key)
    }
}
