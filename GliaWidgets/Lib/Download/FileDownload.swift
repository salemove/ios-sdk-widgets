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

    init(with file: ChatEngagementFile, storage: DataStorage) {
        self.file = file
        self.storage = storage

        if file.isDeleted == true {
            state.value = .error(.deleted)
        } else if let storageID = storageID, storage.hasData(for: storageID) {
            let url = storage.url(for: storageID)
            let localFile = LocalFile(with: url)
            state.value = .downloaded(localFile)
        }
    }

    func startDownload() {
        guard let fileUrl = file.url else {
            state.value = .error(.missingFileURL)
            return
        }

        let engagementFile = SalemoveSDK.EngagementFile(
            url: fileUrl
        )

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

        Salemove.sharedInstance.fetchFile(
            engagementFile: engagementFile,
            progress: onProgress,
            completion: onCompletion
        )
    }
}
