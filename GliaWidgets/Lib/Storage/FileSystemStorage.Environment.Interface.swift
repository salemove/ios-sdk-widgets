import Foundation

extension FileSystemStorage {
    struct Environment {
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
    }
}
