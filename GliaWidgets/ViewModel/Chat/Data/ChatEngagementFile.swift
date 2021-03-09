import SalemoveSDK

class ChatEngagementFile: Codable {
    let id: String?
    let url: URL?
    let name: String?
    let size: Double?

    init(with file: SalemoveSDK.EngagementFile) {
        id = file.id
        url = file.url
        name = file.name
        size = file.size
    }
}
