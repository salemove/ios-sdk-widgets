import SalemoveSDK

public struct MessageAlertConfiguration {
    public var title: String?
    public var message: String?

    private let kMessagePlaceholder = "{message}"

    public init(title: String?, message: String?) {
        self.title = title
        self.message = message
    }

    init(with error: SalemoveError, templateConf: MessageAlertConfiguration) {
        self.title = templateConf.title
        self.message = templateConf.message?.replacingOccurrences(of: kMessagePlaceholder,
                                                                  with: error.reason)
    }
}
