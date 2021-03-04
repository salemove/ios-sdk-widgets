class FileUploader {
    enum State {
        case none
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
    var count: Int { return uploads.count }
    let state = ValueProvider<State>(with: .none)

    private var uploads = [FileUpload]()

    init() {}

    subscript(index: Int) -> FileUpload {
        return uploads[index]
    }

    func addUpload(with url: URL) {
        state.value = .uploading
        let upload = FileUpload(with: url)
        upload.state.addObserver(self) { state, _ in
            switch state {
            case .uploaded:
                self.checkFinished()
            case .error:
                self.checkFinished()
            default:
                break
            }
        }
        uploads.append(upload)
        upload.startUpload()
    }

    func removeUpload(at index: Int) {
        uploads.remove(at: index)
        checkFinished()
    }

    private func checkFinished() {
        let totalFinished = succeededUploads.count + failedUploads.count
        if totalFinished == count {
            state.value = .finished
        }
    }
}
