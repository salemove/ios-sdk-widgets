import SalemoveSDK

class ChatEngagementFile: Codable {
    let id: String?
    let url: URL?
    let name: String?
    let size: Double?
    let contentType: String?
    let isDeleted: Bool?

    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case name
        case size
        case contentType
        case isDeleted
    }

    init(with file: SalemoveSDK.EngagementFile) {
        id = file.id
        url = file.url
        name = file.name
        size = file.size
        contentType = file.contentType
        isDeleted = file.isDeleted
    }
}

extension ChatEngagementFile {
    var isImage: Bool {
        let contentType = self.contentType ?? ""
        let fileName = name ?? ""
        return contentType.hasPrefix("image") || fileName.hasImageFileExtension
    }
}

extension ChatEngagementFile: FileDownloadable {}
