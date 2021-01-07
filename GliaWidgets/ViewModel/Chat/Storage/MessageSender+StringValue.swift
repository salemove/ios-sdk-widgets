import SalemoveSDK

extension MessageSender {
    private enum StringValue: String {
        case visitor
        case `operator`
        case omniguide
        case system

        init(with sender: MessageSender) {
            switch sender {
            case .visitor:
                self = .visitor
            case .operator:
                self = .operator
            case .omniguide:
                self = .omniguide
            case .system:
                self = .system
            }
        }
    }

    var stringValue: String { return StringValue(with: self).rawValue }

    init?(stringValue: String) {
        guard let value = StringValue(rawValue: stringValue) else { return nil }

        switch value {
        case .visitor:
            self = .visitor
        case .operator:
            self = .operator
        case .omniguide:
            self = .omniguide
        case .system:
            self = .system
        }
    }
}
