class FileSystemCache: Cache {
    private let storageURL: URL
    private let kCacheDirectory = "GliaFileCache"
    private let kExpirationSeconds: Double = 7 * 24 * 60 * 60

    init() {
        storageURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(kCacheDirectory)
        createStorage()
    }

    deinit {
        sweep()
    }

    func store(_ data: Data, for key: String) {
        let url = storageURL(for: key)
        try? data.write(to: url)
    }

    func url(for key: String) -> URL? {
        return storageURL(for: key)
    }

    func data(for key: String) -> Data? {
        let url = storageURL(for: key)
        return try? Data(contentsOf: url)
    }

    func hasData(for key: String) -> Bool {
        let url = storageURL(for: key)
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }

    private func storageURL(for key: String) -> URL {
        return storageURL.appendingPathComponent(key)
    }

    private func createStorage() {
        try? FileManager.default.createDirectory(at: storageURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
    }

    private func sweep() {
        let now = Date().timeIntervalSince1970
        let files = try? FileManager.default.contentsOfDirectory(atPath: storageURL.path)

        files?.forEach {
            let filePath = storageURL.appendingPathComponent($0).path
            if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
               let created = attributes[FileAttributeKey.creationDate] as? Date,
               created.timeIntervalSince1970 + kExpirationSeconds < now {
                try? FileManager.default.removeItem(atPath: filePath)
            }
        }
    }
}
