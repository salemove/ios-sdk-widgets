import Foundation

extension FileSystemStorage {
    struct Environment {
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
    }
}

extension FileSystemStorage.Environment {
    static func create(with environment: FileDownloader.Environment) -> Self {
        .init(
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date
        )
    }

    static func create(with environment: FileUploader.Environment) -> Self {
        .init(
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date
        )
    }
}
