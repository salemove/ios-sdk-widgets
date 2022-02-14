extension FoundationBased.FileManager {
    static let live = Self(
        urlsForDirectoryInDomainMask: FileManager.default.urls(for:in:),
        fileExistsAtPath: FileManager.default.fileExists(atPath:),
        createDirectoryAtUrlWithIntermediateDirectories: FileManager.default.createDirectory(at:withIntermediateDirectories:attributes:),
        removeItemAtUrl: FileManager.default.removeItem(at:),
        copyItemAtPath: FileManager.default.copyItem(atPath:toPath:),
        contentsOfDirectoryAtPath: FileManager.default.contentsOfDirectory(atPath:),
        attributesOfItemAtPath: FileManager.default.attributesOfItem(atPath:),
        removeItemAtPath: FileManager.default.removeItem(atPath:)
    )
}

extension FoundationBased.Data {
    static let live = Self(
        writeDataToUrl: { data, url in try data.write(to: url) },
        dataWithContentsOfFileUrl: { url in try Foundation.Data(contentsOf: url) }
    )
}
