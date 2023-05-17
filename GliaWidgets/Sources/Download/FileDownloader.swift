import Foundation

class FileDownloader {
    enum AutoDownload {
        case nothing
        case images
    }

    private var downloads = [String: FileDownload]()
    private var storage: FileSystemStorage
    private var environment: Environment

    init(environment: Environment) {
        self.environment = environment
        self.storage = FileSystemStorage(
            directory: .documents(environment.fileManager),
            environment: .init(
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date
            )
        )
    }

    func downloads(for files: [ChatEngagementFile]?,
                   autoDownload: AutoDownload = .nothing) -> [FileDownload] {
        guard let files = files else { return [] }

        let downloads = files.compactMap { download(for: $0) }

        switch autoDownload {
        case .images:
            downloadImages(for: downloads)
        case .nothing:
            break
        }

        return downloads
    }

    func download(for file: ChatEngagementFile) -> FileDownload? {
        guard let fileID = file.id else { return nil }

        if let download = downloads[fileID] {
            return download
        } else {
            return addDownload(for: file)
        }
    }

    func addDownloads(for files: [ChatEngagementFile]?) {
        guard let files = files else { return }

        files.forEach { [weak self] in
            self?.addDownload(for: $0)
        }
    }

    @discardableResult
    private func addDownload(for file: ChatEngagementFile) -> FileDownload? {
        guard let fileID = file.id else { return nil }

        if let download = downloads[fileID] {
            return download
        } else {
            let download = environment.createFileDownload(
                file,
                storage,
                .init(
                    fetchFile: environment.fetchFile,
                    downloadSecureFile: environment.downloadSecureFile,
                    fileManager: environment.fileManager,
                    gcd: environment.gcd,
                    uiScreen: environment.uiScreen,
                    createThumbnailGenerator: environment.createThumbnailGenerator
                )
            )

            downloads[fileID] = download
            return download
        }
    }

    private func downloadImages(for downloads: [FileDownload]) {
        downloads
            .filter { $0.file.isImage }
            .filter {
                switch $0.state.value {
                case .none, .error:
                    return true
                case .downloading, .downloaded:
                    return false
                }
            }
            .forEach { $0.startDownload() }
    }
}

extension FileDownloader {
    typealias CreateFileDownload = (
        _ file: ChatEngagementFile,
        _ storage: DataStorage,
        _ environment: FileDownload.Environment
    ) -> FileDownload

    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: CreateFileDownload
    }
}
