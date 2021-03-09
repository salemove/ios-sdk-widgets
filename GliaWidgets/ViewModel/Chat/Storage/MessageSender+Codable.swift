import SalemoveSDK

extension SalemoveSDK.MessageSender: Codable {
    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    var rawValue: Int {
        switch self {
        case .visitor:
            return 0
        case .operator:
            return 1
        case .omniguide:
            return 2
        case .system:
            return 3
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .visitor
        case 1:
            self = .operator
        case 2:
            self = .omniguide
        case 3:
            self = .system
        default:
            throw CodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
}
