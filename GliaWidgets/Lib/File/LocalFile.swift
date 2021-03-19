class LocalFile {
    lazy var isImage: Bool = { return url.path.hasImageFileExtension }()
    lazy var fileExtension: String = { return url.pathExtension }()
    lazy var fileName: String = { return url.lastPathComponent }()
    lazy var fileSize: Int64? = {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else { return nil }
        return attributes[.size] as? Int64
    }()
    lazy var fileSizeString: String? = {
        guard let fileSize = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }()
    lazy var fileInfoString: String? = {
        if !fileName.isEmpty, let fileSizeString = fileSizeString {
            return "\(fileName) • \(fileSizeString)"
        } else if !fileName.isEmpty {
            return fileName
        } else if let fileSizeString = fileSizeString {
            return fileSizeString
        } else {
            return nil
        }
    }()

    let url: URL

    init(with url: URL) {
        self.url = url
    }
}

extension LocalFile: Equatable {
    static func == (lhs: LocalFile, rhs: LocalFile) -> Bool {
        return lhs.url == rhs.url
    }
}
