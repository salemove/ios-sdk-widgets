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
    let state = ObservableValue<State>(with: .idle)

    private var uploads = [FileUpload]()
    private var storage = FileSystemStorage(directory: .documents)

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

    func addUpload(with data: Data, format: MediaFormat) -> FileUpload? {
        let fileName = UUID().uuidString + "." + format.fileExtension
        let url = storage.url(for: fileName)
        do {
            try data.write(to: url)
            return addUpload(with: url)
        } catch {
            return nil
        }
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

        if !uploads.isEmpty {
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
