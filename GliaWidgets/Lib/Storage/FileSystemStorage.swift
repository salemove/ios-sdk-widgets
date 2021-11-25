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
    private let fileManager = FileManager()

    init(directory: Directory, expiration: Expiration = .none) {
        self.directory = directory
        self.expiration = expiration
        createStorage()
    }

    deinit {
        sweep()
    }

    func store(_ data: Data, for key: String) {
        let url = storageURL(for: key)

        if !fileManager.fileExists(atPath: url.deletingPathExtension().path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }

        try? data.write(to: url)
    }

    func store(from url: URL, for key: String) {
        let sourcePath = url.path
        let targetUrl = storageURL(for: key)

        if !fileManager.fileExists(atPath: targetUrl.deletingPathExtension().path) {
            try? fileManager.createDirectory(at: targetUrl, withIntermediateDirectories: true, attributes: nil)
        }

        if fileManager.fileExists(atPath: targetUrl.path) {
            try? fileManager.removeItem(at: targetUrl)
        }

        try? fileManager.copyItem(atPath: sourcePath, toPath: targetUrl.path)
    }

    func url(for key: String) -> URL {
        return storageURL(for: key)
    }

    func data(for key: String) -> Data? {
        let url = storageURL(for: key)
        return try? Data(contentsOf: url)
    }

    func hasData(for key: String) -> Bool {
        let url = storageURL(for: key)
        return fileManager.fileExists(atPath: url.path)
    }

    func removeData(for key: String) {
        let url = storageURL(for: key)
        try? fileManager.removeItem(atPath: url.path)
    }

    private func storageURL(for key: String) -> URL {
        let components = key.split(separator: "/")
        var baseUrl = directory.url

        for directoryComponent in components.indices.dropLast() {
            baseUrl = baseUrl.appendingPathComponent(
                String(components[directoryComponent]),
                isDirectory: true
            )
        }

        if let lastComponent = components.last {
            return baseUrl.appendingPathComponent(String(lastComponent))
        } else {
            return baseUrl.appendingPathComponent(key)
        }
    }

    private func createStorage() {
        try? fileManager.createDirectory(at: directory.url,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
    }

    private func sweep() {
        guard case .seconds(let expirationSeconds) = expiration else { return }

        let now = Date().timeIntervalSince1970
        let files = try? fileManager.contentsOfDirectory(atPath: directory.url.path)

        files?.forEach {
            let filePath = directory.url.appendingPathComponent($0).path
            if let attributes = try? fileManager.attributesOfItem(atPath: filePath),
               let created = attributes[FileAttributeKey.creationDate] as? Date,
               created.timeIntervalSince1970 + expirationSeconds < now {
                try? fileManager.removeItem(atPath: filePath)
            }
        }
    }
}
