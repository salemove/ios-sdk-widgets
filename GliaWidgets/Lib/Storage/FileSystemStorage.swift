class FileSystemStorage: DataStorage {
    enum Directory {
        case documents

        var url: URL {
            switch self {
            case .documents:
                let paths = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                return paths[0]
            }
        }
    }

    enum Expiration {
        case none
        case seconds(Double)
    }

    private let directory: Directory
    private let expiration: Expiration

    init(directory: Directory, expiration: Expiration) {
        self.directory = directory
        self.expiration = expiration
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
        return FileManager.default.fileExists(atPath: url.path)
    }

    private func storageURL(for key: String) -> URL {
        return directory.url.appendingPathComponent(key)
    }

    private func createStorage() {
        try? FileManager.default.createDirectory(at: directory.url,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
    }

    private func sweep() {
        guard case .seconds(let expirationSeconds) = expiration else { return }

        let now = Date().timeIntervalSince1970
        let files = try? FileManager.default.contentsOfDirectory(atPath: directory.url.path)

        files?.forEach {
            let filePath = directory.url.appendingPathComponent($0).path
            if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
               let created = attributes[FileAttributeKey.creationDate] as? Date,
               created.timeIntervalSince1970 + expirationSeconds < now {
                try? FileManager.default.removeItem(atPath: filePath)
            }
        }
    }
}
