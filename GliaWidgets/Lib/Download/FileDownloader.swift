import SalemoveSDK

class FileDownloader<File: FileDownloadable> {
    enum AutoDownload {
        case nothing
        case images
    }

    private var downloads = [String: FileDownload<File>]()
    private var storage = FileSystemStorage(directory: .documents,
                                            expiration: .none)

    func downloads(for files: [File]?,
                   autoDownload: AutoDownload = .nothing) -> [FileDownload<File>] {
        guard let files = files else { return [] }

        let downloads = files.compactMap({ download(for: $0) })

        switch autoDownload {
        case .images:
            downloadImages(for: downloads)
        case .nothing:
            break
        }

        return downloads
    }

    func download(for file: File) -> FileDownload<File>? {
        guard let fileID = file.id else { return nil }

        if let download = downloads[fileID] {
            return download
        } else {
            let download = FileDownload<File>(with: file, storage: storage)
            downloads[fileID] = download
            return download
        }
    }

    private func downloadImages(for downloads: [FileDownload<File>]) {
        downloads
            .filter({ $0.file.isImage })
            .filter({
                switch $0.state.value {
                case .none, .error:
                    return true
                case .downloading, .downloaded:
                    return false
                }
            })
            .forEach({ $0.startDownload() })
    }
}
