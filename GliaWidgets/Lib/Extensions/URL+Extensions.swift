extension URL {
    var fileName: String? {
        if lastPathComponent.isEmpty {
            return nil
        } else {
            return lastPathComponent
        }
    }

    var fileSize: Int64? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: absoluteString) else { return nil }
        return attributes[.size] as? Int64
    }

    var fileSizeString: String? {
        guard let fileSize = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}
