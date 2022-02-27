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
    var attachment: CoreSdkClient.Attachment? {
        guard !succeededUploads.isEmpty else { return nil }
        let files = succeededUploads
            .compactMap { $0.engagementFileInformation }
            .map { CoreSdkClient.EngagementFile(id: $0.id) }
        return CoreSdkClient.Attachment(files: files)
    }
    var count: Int { return uploads.count }
    let state = ObservableValue<State>(with: .idle)
    let limitReached = ObservableValue<Bool>(with: false)
    var uploads = [FileUpload]()

    private var storage: FileSystemStorage
    private let maximumUploads: Int
    private let environment: Environment

    init(maximumUploads: Int, environment: Environment) {
        self.maximumUploads = maximumUploads
        self.environment = environment
        self.storage = FileSystemStorage(
            directory: .documents(environment.fileManager),
            environment: .init(
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date
            )
        )
        updateLimitReached()
    }

    func addUpload(with url: URL) -> FileUpload? {
        guard !limitReached.value else { return nil }

        let localFile = LocalFile(with: url)
        let upload = FileUpload(
            with: localFile,
            storage: storage,
            environment: .init(
                uploadFileToEngagement: environment.uploadFileToEngagement,
                uuid: environment.uuid
            )
        )

        upload.state.addObserver(self) { [weak self] _, _ in
            self?.updateState()
        }
        uploads.append(upload)
        upload.startUpload()
        updateState()
        updateLimitReached()
        return upload
    }

    func addUpload(with data: Data, format: MediaFormat) -> FileUpload? {
        guard !limitReached.value else { return nil }
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
        uploads.removeAll(where: { $0.uuid == upload.uuid })
        upload.removeLocalFile()
        updateState()
        updateLimitReached()
    }

    func removeSucceededUploads() {
        uploads.removeAll(where: { upload in
            switch upload.state.value {
            case .uploaded:
                return true
            default:
                return false
            }
        })
        updateState()
        updateLimitReached()
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

    private func updateLimitReached() {
        limitReached.value = count >= maximumUploads
    }
}

extension FileUploader {
    struct Environment {
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var uuid: () -> UUID
    }
}
