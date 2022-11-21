import GliaWidgets
import SalemoveSDK

extension Environment {
    var gliaCoreRegion: GliaCore.Region {
        switch self {
        case .europe:
            return .eu
        case .usa:
            return .us
        case .beta:
            return .custom(URL(string: "https://api.beta.salemove.com")!)
        case .custom(let url):
            return .custom(url)
        }
    }
}
