import SalemoveSDK

class ChatOperator: Codable {
    let name: String
    let pictureUrl: String?

    init(with salemoveOperator: SalemoveSDK.Operator) {
        name = salemoveOperator.name
        pictureUrl = salemoveOperator.picture?.url
    }
}
