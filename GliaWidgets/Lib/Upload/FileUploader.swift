import SalemoveSDK

class FileUploader {
    enum State {
        case idle
        case uploading
        case finished
    }

    var activeUploads: [FileUpload] {
        return uploads.filter {
            switch $0.state.value {
            case .uploading:
                return true
            default:
                return false
            }
        }
    }
    var succeededUploads: [FileUpload] {
        return uploads.filter {
            switch $0.state.value {
            case .uploaded:
                return true
            default:
                return false
            }
        }
    }
    var failedUploads: [FileUpload] {
        return uploads.filter {
            switch $0.state.value {
            case .error:
                return true
            default:
                return false
            }
        }
    }
    var attachment: Attachment? {
        guard !succeededUploads.isEmpty else { return nil }
        let files = succeededUploads
            .compactMap { $0.engagementFileInformation }
            .map { EngagementFile(id: $0.id) }
        return Attachment(files: files)
    }
    var count: Int { return uploads.count }
    let state = ValueProvider<State>(with: .idle)

    private var uploads = [FileUpload]()
    private var storage = FileSystemStorage(directory: .documents)

    init() {}

    func addUpload(with url: URL) -> FileUpload {
        let localFile = LocalFile(with: url)
        let upload = FileUpload(with: localFile, storage: storage)
        upload.state.addObserver(self) { _, _ in
            self.updateState()
        }
        uploads.append(upload)
        upload.startUpload()
        updateState()
        return upload
    }

    func upload(at index: Int) -> FileUpload? {
        guard uploads.indices ~= index else { return nil }
        return uploads[index]
    }

    func removeUpload(_ upload: FileUpload) {
        uploads.removeAll(where: { $0 == upload })
        upload.removeLocalFile()
        updateState()
    }

    func removeAllUploads() {
        uploads.removeAll()
        updateState()
    }

    private func updateState() {
        var newState: State = .idle

        if uploads.isEmpty {
            newState = .idle
        } else {
            if activeUploads.isEmpty {
                newState = .finished
            } else {
                newState = .uploading
            }
        }

        if state.value != newState {
            state.value = newState
        }
    }
}
