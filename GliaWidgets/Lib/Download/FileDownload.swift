import SalemoveSDK

class FileDownload {
    enum Error {
        case network
        case generic
        case missingFileURL
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
        case downloading(progress: Observable<Double>)
        case downloaded(LocalFile)
        case error(Error)
    }

    var state: Observable<State> {
        stateSubject
    }

    let file: ChatEngagementFile

    private let stateSubject = CurrentValueSubject<State>(.none)

    private var storageID: String? {
        if let fileID = file.id, let fileName = file.name {
            return "\(fileID)/\(fileName)"
        } else {
            return nil
        }
    }
    private let storage: DataStorage

    init(with file: ChatEngagementFile, storage: DataStorage) {
        self.file = file
        self.storage = storage

        if file.isDeleted == true {
            stateSubject.send(.error(.deleted))
        } else if let storageID = storageID, storage.hasData(for: storageID) {
            let url = storage.url(for: storageID)
            let localFile = LocalFile(with: url)
            stateSubject.send(.downloaded(localFile))
        }
    }

    func startDownload() {
        guard let fileUrl = file.url else {
            stateSubject.value = .error(.missingFileURL)
            return
        }

        let engagementFile = EngagementFile(url: fileUrl)
        let progressSubject = CurrentValueSubject<Double>(0)

        let onProgress: EngagementFileProgressBlock = {
            if case .downloading = self.stateSubject.value {
                progressSubject.send($0.fractionCompleted)
            }
        }

        let onCompletion: EngagementFileFetchCompletionBlock = { data, error in
            if let data = data, let storageID = self.storageID {
                let url = self.storage.url(for: storageID)
                let file = LocalFile(with: url)
                self.storage.store(data.data, for: storageID)
                self.stateSubject.send(.downloaded(file))
            } else if let error = error {
                self.stateSubject.send(.error(Error(with: error)))
            }
        }

        stateSubject.send(.downloading(progress: progressSubject))

        Salemove.sharedInstance.fetchFile(
            engagementFile: engagementFile,
            progress: onProgress,
            completion: onCompletion
        )
    }
}
