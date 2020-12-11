import SalemoveSDK

public struct VisitorContext {
    public enum ContextType {
        case page

        var contextType: SalemoveSDK.ContextType {
            switch self {
            case .page:
                return .page
            }
        }
    }

    public let type: ContextType
    public let url: String

    var apiContext: SalemoveSDK.VisitorContext {
        return .init(type: type.contextType, url: url)
    }

    public init(type: ContextType, url: String) {
        self.type = type
        self.url = url
    }
}
