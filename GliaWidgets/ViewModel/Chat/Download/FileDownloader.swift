import SalemoveSDK

class FileDownloader {
    private var downloads = [String: FileDownload]()
    private var cache = FileSystemCache()

    func download(for file: EngagementFile) -> FileDownload? {
        guard let fileID = file.id else { return nil }

        if let download = downloads[fileID] {
            return download
        } else {
            let download = FileDownload(with: file, cache: cache)
            downloads[fileID] = download
            return download
        }
    }
}
