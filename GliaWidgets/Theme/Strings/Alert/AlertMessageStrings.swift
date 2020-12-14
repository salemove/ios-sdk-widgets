
import SalemoveSDK
public struct AlertMessageStrings {
    public var title: String?
    public var message: String?

    private let kMessagePlaceholder = "{message}"

    public init(title: String?, message: String?) {
        self.title = title
        self.message = message
    }

    init(with error: SalemoveError, templateStrings: AlertMessageStrings) {
        self.title = templateStrings.title
        self.message = templateStrings.message?.replacingOccurrences(of: kMessagePlaceholder,
                                                                     with: error.reason)
    }
}
