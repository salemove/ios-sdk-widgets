import Foundation

/// Glia's environment. Use the one that our account manager has assigned to you.
public enum Environment {
    /// Europe
    case europe

    /// USA
    case usa

    /// Beta environment. For development use.
    case beta

    /// Custom environment. For development use.
    case custom(URL)

    var region: CoreSdkClient.Salemove.Region {
        switch self {
        case .usa:
            return .us
        case .europe:
            return .eu
        case .beta:
            // swiftlint:disable force_unwrapping
            return .custom(URL(string: "https://beta.salemove.com/")!)
            // swiftlint:enable force_unwrapping
        case .custom(let url):
            return .custom(url)
        }
    }
}
