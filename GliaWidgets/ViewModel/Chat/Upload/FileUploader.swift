import SalemoveSDK

class FileUploader {
    enum State {
        case idle
        case uploading
        case finished
    }

    var succeededUploads: [FileUpload] {
        return uploads.filter({
            switch $0.state.value {
            case .uploaded:
                return true
            default:
                return false
            }
        })
    }
    var failedUploads: [FileUpload] {
        return uploads.filter({
            switch $0.state.value {
            case .error:
                return true
            default:
                return false
            }
        })
    }
    var attachment: Attachment? {
        guard !succeededUploads.isEmpty else { return nil }
        let files = succeededUploads
            .compactMap({ $0.engagementFileInformation })
            .map({ EngagementFile(id: $0.id) })
        return Attachment(files: files)
    }
    var count: Int { return uploads.count }
    let state = ValueProvider<State>(with: .idle)

    private var uploads = [FileUpload]()

    init() {}

    subscript(index: Int) -> FileUpload {
        return uploads[index]
    }

    func addUpload(with url: URL) -> FileUpload {
        let upload = FileUpload(with: url)
        upload.state.addObserver(self) { _, _ in
            self.updateState()
        }
        uploads.append(upload)
        upload.startUpload()
        updateState()
        return upload
    }

    func removeUpload(at index: Int) {
        guard uploads.indices ~= index else { return }
        uploads.remove(at: index)
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
            let totalFinished = succeededUploads.count + failedUploads.count
            if totalFinished == uploads.count {
                state.value = .finished
            } else {
                newState = .uploading
            }
        }

        if state.value != newState {
            state.value = newState
        }
    }
}
