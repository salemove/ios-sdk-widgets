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
        case downloading(file: ChatEngagementFile, progress: ValueProvider<Double>)
        case downloaded(file: ChatEngagementFile, url: URL)
        case error(Error)
    }

    var localURL: URL? {
        guard let id = file.id else { return nil }
        return storage.url(for: id)
    }
    var localData: Data? {
        guard let id = file.id else { return nil }
        return storage.data(for: id)
    }

    let state = ValueProvider<State>(with: .none)
    let file: ChatEngagementFile

    private let storage: DataStorage

    init(with file: ChatEngagementFile, storage: DataStorage) {
        self.file = file
        self.storage = storage

        if file.isDeleted == true {
            state.value = .error(.deleted)
        } else if let id = file.id, storage.hasData(for: id) {
            state.value = .downloaded(file: file,
                                      url: storage.url(for: id))
        }
    }

    func startDownload() {
        guard let fileID = file.id else {
            state.value = .error(.missingFileID)
            return
        }

        let progress = ValueProvider<Double>(with: 0)
        let onProgress: EngagementFileProgressBlock = {
            if case .downloading(_, progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }
        let onCompletion: EngagementFileFetchCompletionBlock = { data, error in
            if let data = data {
                self.storage.store(data.data, for: fileID)
                self.state.value = .downloaded(file: self.file,
                                               url: self.storage.url(for: fileID))
            } else if let error = error {
                self.state.value = .error(Error(with: error))
            }
        }

        state.value = .downloading(file: file, progress: progress)
        Salemove.sharedInstance.fetchFile(fileID,
                                          progress: onProgress,
                                          completion: onCompletion)
    }
}
