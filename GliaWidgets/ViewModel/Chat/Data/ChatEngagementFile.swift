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
        return contentType?.hasPrefix("image") == true
    }
}

extension ChatEngagementFile {
    var fileExtension: String? {
        let components = name?.split(separator: ".") ?? []
        if components.count > 1, let fileExtension = components.last {
            return String(fileExtension)
        } else {
            return nil
        }
    }

    var sizeString: String? {
        guard let size = size else { return nil }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }

    var fileInfoString: String? {
        if let name = name, let sizeString = sizeString {
            return "\(name) • \(sizeString)"
        } else if let name = name {
            return name
        } else if let sizeString = sizeString {
            return sizeString
        } else {
            return nil
        }
    }
}

extension ChatEngagementFile: FileDownloadable {}
