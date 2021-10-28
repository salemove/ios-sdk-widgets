import SalemoveSDK

class FileDownload {
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
        case downloading(progress: ObservableValue<Double>)
        case downloaded(LocalFile)
        case error(Error)
    }

    let state = ObservableValue<State>(with: .none)
    let file: ChatEngagementFile

    private var storageID: String? {
        if let fileID = file.id, let fileName = file.name {
            return "\(fileID)/\(fileName)"
        } else {
            return nil
        }
    }
    private let storage: DataStorage

    init(with file: ChatEngagementFile, storage: DataStorage, localFile: LocalFile? = nil) {
        self.file = file
        self.storage = storage

        if file.isDeleted == true {
            state.value = .error(.deleted)
        } else if let localFile = localFile {
            state.value = .downloaded(localFile)
        } else if let storageID = storageID, storage.hasData(for: storageID) {
            let url = storage.url(for: storageID)
            let localFile = LocalFile(with: url)
            state.value = .downloaded(localFile)
        }
    }

    func startDownload() {
        guard let fileID = file.id else {
            state.value = .error(.missingFileID)
            return
        }

        let progress = ObservableValue<Double>(with: 0)
        let onProgress: EngagementFileProgressBlock = {
            if case .downloading(progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }
        let onCompletion: EngagementFileFetchCompletionBlock = { data, error in
            if let data = data, let storageID = self.storageID {
                let url = self.storage.url(for: storageID)
                let file = LocalFile(with: url)
                self.storage.store(data.data, for: storageID)
                self.state.value = .downloaded(file)
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
