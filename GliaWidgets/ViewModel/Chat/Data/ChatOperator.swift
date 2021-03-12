import SalemoveSDK

class ChatOperator: Codable {
    let name: String
    let pictureUrl: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case pictureUrl
    }

    init(with salemoveOperator: SalemoveSDK.Operator) {
        name = salemoveOperator.name
        pictureUrl = salemoveOperator.picture?.url
    }
}
