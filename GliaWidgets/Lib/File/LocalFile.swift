class LocalFile {
    var isImage: Bool { return url.path.hasImageFileExtension }
    var fileExtension: String { return url.pathExtension }
    var fileName: String? {
        if url.lastPathComponent.isEmpty {
            return nil
        } else {
            return url.lastPathComponent
        }
    }
    var fileSize: Int64? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else { return nil }
        return attributes[.size] as? Int64
    }
    var fileSizeString: String? {
        guard let fileSize = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }

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
