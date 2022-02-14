import Foundation

class FileSystemStorage: DataStorage {
    enum Directory {
        case documents(FoundationBased.FileManager)

        var url: URL {
            switch self {
            case let .documents(fileManager):
                let paths = fileManager.urlsForDirectoryInDomainMask(
                        .documentDirectory,
                        .userDomainMask
                )
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
    var environment: Environment

    init(
        directory: Directory,
        expiration: Expiration = .none,
        environment: Environment
    ) {
        self.directory = directory
        self.expiration = expiration
        self.environment = environment
        createStorage()
    }

    deinit {
        sweep()
    }

    func store(_ data: Data, for key: String) {
        let url = storageURL(for: key)

        if !environment.fileManager.fileExistsAtPath(url.deletingPathExtension().path) {
            try? environment.fileManager.createDirectoryAtUrlWithIntermediateDirectories(
                url, // atURL
                true, // withIntermediateDirectories
                nil // attributes
            )
        }

        if environment.fileManager.fileExistsAtPath(url.path) {
            try? environment.fileManager.removeItemAtUrl(url)
        }

        try? environment.data.writeDataToUrl(data, url)
    }

    func store(from url: URL, for key: String) {
        let sourcePath = url.path
        let targetUrl = storageURL(for: key)

        if !environment.fileManager.fileExistsAtPath(targetUrl.deletingPathExtension().path) {
            try? environment.fileManager.createDirectoryAtUrlWithIntermediateDirectories(
                targetUrl, // atURL
                true, // withIntermediateDirectories
                nil // attributes
            )
        }

        if environment.fileManager.fileExistsAtPath(targetUrl.path) {
            try? environment.fileManager.removeItemAtUrl(targetUrl)
        }

        try? environment.fileManager.copyItemAtPath(sourcePath, targetUrl.path)
    }

    func url(for key: String) -> URL {
        return storageURL(for: key)
    }

    func data(for key: String) -> Data? {
        let url = storageURL(for: key)
        return try? environment.data.dataWithContentsOfFileUrl(url)
    }

    func hasData(for key: String) -> Bool {
        let url = storageURL(for: key)
        return environment.fileManager.fileExistsAtPath(url.path)
    }

    func removeData(for key: String) {
        let url = storageURL(for: key)
        try? environment.fileManager.removeItemAtPath(url.path)
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
        try? environment.fileManager.createDirectoryAtUrlWithIntermediateDirectories(
            directory.url, // atURL
            true, // withIntermediateDirectories
            nil // attributes
        )
    }

    private func sweep() {
        guard case .seconds(let expirationSeconds) = expiration else { return }

        let now = environment.date().timeIntervalSince1970
        let files = try? environment.fileManager.contentsOfDirectoryAtPath(directory.url.path)

        files?.forEach {
            let filePath = directory.url.appendingPathComponent($0).path
            if let attributes = try? environment.fileManager.attributesOfItemAtPath(filePath),
               let created = attributes[FileAttributeKey.creationDate] as? Date,
               created.timeIntervalSince1970 + expirationSeconds < now {
                try? environment.fileManager.removeItemAtPath(filePath)
            }
        }
    }
}

extension FileSystemStorage {
    struct Environment {
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
    }
}
