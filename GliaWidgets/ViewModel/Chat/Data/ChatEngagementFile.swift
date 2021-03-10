import SalemoveSDK

class ChatEngagementFile: Codable {
    let id: String?
    let url: URL?
    let name: String?
    let size: Double?
    let contentType: String?
    let isDeleted: Bool?

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
        let fileExtension = name?.split(separator: ".").last?.lowercased() ?? ""
        let isImage = contentType.hasPrefix("image") ||
            ["jpg", "jpeg", "png", "gif", "tif", "tiff", "bmp"].contains(fileExtension)
        return isImage
    }
}
