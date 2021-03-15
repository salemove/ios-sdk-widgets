import SalemoveSDK

class FileDownload<File: FileDownloadable> {
    enum Error {
        case network
        case generic
        case missingFileID
        case deleted

        init(with error: SalemoveError) {
            switch error.error {
            case let genericError as GeneralError:
                switch genericError {
                case .networkError:
                    self = .network
                default:
                    self = .generic
                }
            default:
                self = .generic
            }
        }
    }

    enum State {
        case none
        case downloading(progress: ValueProvider<Double>)
        case downloaded(LocalFile)
        case error(Error)
    }

    let state = ValueProvider<State>(with: .none)
    let file: File

    private let storage: DataStorage

    init(with file: File, storage: DataStorage) {
        self.file = file
        self.storage = storage

        if file.isDeleted == true {
            state.value = .error(.deleted)
        } else if let id = file.id, storage.hasData(for: id) {
            let url = storage.url(for: id)
            state.value = .downloaded(LocalFile(with: url))
        }
    }

    func startDownload() {
        guard let fileID = file.id else {
            state.value = .error(.missingFileID)
            return
        }

        let progress = ValueProvider<Double>(with: 0)
        let onProgress: EngagementFileProgressBlock = {
            if case .downloading(progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }
        let onCompletion: EngagementFileFetchCompletionBlock = { data, error in
            if let data = data {
                let url = self.storage.url(for: fileID)
                self.storage.store(data.data, for: fileID)
                self.state.value = .downloaded(LocalFile(with: url))
            } else if let error = error {
                self.state.value = .error(Error(with: error))
            }
        }

        state.value = .downloading(progress: progress)
        Salemove.sharedInstance.fetchFile(fileID,
                                          progress: onProgress,
                                          completion: onCompletion)
    }
}
