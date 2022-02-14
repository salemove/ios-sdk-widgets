import Foundation

enum FoundationBased {
    struct FileManager {
        var urlsForDirectoryInDomainMask: (
            _ forDirectory: Foundation.FileManager.SearchPathDirectory,
            _ inDomainMask: Foundation.FileManager.SearchPathDomainMask
        ) -> [URL]

        var fileExistsAtPath:(_ atPath: String) -> Bool

        var createDirectoryAtUrlWithIntermediateDirectories:(
            _ atURL: URL,
            _ withIntermediateDirectories: Bool,
            _ attributes: [FileAttributeKey: Any]?
        ) throws -> Void

        var removeItemAtUrl: (_ atURL: URL) throws -> Void

        var copyItemAtPath: (
            _ atPath: String,
            _ toPath: String
        ) throws -> Void

        var contentsOfDirectoryAtPath: (_ atPath: String) throws -> [String]

        var attributesOfItemAtPath: (_ atPath: String) throws -> [FileAttributeKey: Any]

        var removeItemAtPath: (_ atPath: String) throws -> Void
    }

    struct Data {
        var writeDataToUrl: (
            _ data: Foundation.Data,
            _ toUrl: URL
        ) throws -> Void

        var dataWithContentsOfFileUrl: (
            _ contentsOfUrl: URL
        ) throws -> Foundation.Data
    }
}
