import SalemoveSDK

class FileUpload {
    enum Error {
        case fileTooBig
        case unsupportedFileType
        case safetyCheckFailed
        case network
        case generic

        init(with error: SalemoveError) {
            switch error.error {
            case let genericError as GeneralError:
                switch genericError {
                case .networkError:
                    self = .network
                default:
                    self = .generic
                }
            case let fileError as FileError:
                switch fileError {
                case .fileTooBig:
                    self = .fileTooBig
                case .unsupportedFileType:
                    self = .unsupportedFileType
                case .infected:
                    self = .safetyCheckFailed
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
        case uploading(progress: ObservableValue<Double>)
        case uploaded(file: EngagementFileInformation)
        case error(Error)
    }

    var engagementFileInformation: EngagementFileInformation? {
        switch state.value {
        case .uploaded(file: let file):
            return file
        default:
            return nil
        }
    }

    let state = ObservableValue<State>(with: .none)
    let localFile: LocalFile

    private let storage: DataStorage

    init(with localFile: LocalFile, storage: DataStorage) {
        self.localFile = localFile
        self.storage = storage
    }

    func startUpload() {
        let file = EngagementFile(url: localFile.url)
        let progress = ObservableValue<Double>(with: 0)
        let onProgress: EngagementFileProgressBlock = {
            if case .uploading(progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }
        let onCompletion: EngagementFileCompletionBlock = { engagementFile, error in
            if let engagementFile = engagementFile {
                let storageID = self.localFile.url.lastPathComponent
                self.storage.store(from: self.localFile.url, for: storageID)
                self.state.value = .uploaded(file: engagementFile)
            } else if let error = error {
                self.state.value = .error(Error(with: error))
            }
        }

        state.value = .uploading(progress: progress)
        Salemove.sharedInstance.uploadFileToEngagement(file,
                                                       progress: onProgress,
                                                       completion: onCompletion)
    }

    func removeLocalFile() {
        guard let id = engagementFileInformation?.id else { return }
        storage.removeData(for: id)
    }
}

extension FileUpload: Equatable {
    static func == (lhs: FileUpload, rhs: FileUpload) -> Bool {
        return lhs.localFile == rhs.localFile
    }
}
