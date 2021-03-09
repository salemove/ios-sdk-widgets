import SalemoveSDK

extension SalemoveSDK.AttachmentType: Codable {
    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    var rawValue: Int {
        switch self {
        case .files:
            return 0
        case .singleChoice:
            return 1
        case .singleChoiceResponse:
            return 2
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .files
        case 1:
            self = .singleChoice
        case 2:
            self = .singleChoiceResponse
        default:
            throw CodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
}
