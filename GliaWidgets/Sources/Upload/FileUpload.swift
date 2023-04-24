import Foundation

class FileUpload {
    enum Error {
        case fileTooBig
        case unsupportedFileType
        case safetyCheckFailed
        case network
        case generic

        init(with error: CoreSdkClient.SalemoveError) {
            switch error.error {
            case let genericError as CoreSdkClient.GeneralError:
                switch genericError {
                case .networkError:
                    self = .network
                default:
                    self = .generic
                }
            case let fileError as CoreSdkClient.FileError:
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
        case uploaded(file: CoreSdkClient.EngagementFileInformation)
        case error(Error)
    }

    var engagementFileInformation: CoreSdkClient.EngagementFileInformation? {
        switch state.value {
        case .uploaded(file: let file):
            return file
        default:
            return nil
        }
    }

    let state = ObservableValue<State>(with: .none)
    let localFile: LocalFile

    lazy var uuid = environment.uuid()

    private let storage: DataStorage
    var environment: Environment

    init(with localFile: LocalFile, storage: DataStorage, environment: Environment) {
        self.localFile = localFile
        self.storage = storage
        self.environment = environment
    }

    func startUpload() {
        let file = CoreSdkClient.EngagementFile(url: localFile.url)
        let progress = ObservableValue<Double>(with: 0)
        let onProgress: CoreSdkClient.EngagementFileProgressBlock = {
            if case .uploading(progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }
        let onCompletion: (Result<CoreSdkClient.EngagementFileInformation, Swift.Error>) -> Void = { result in
            switch result {
            case let .success(engagementFile):
                let storageID = "\(engagementFile.id)/\(self.localFile.url.lastPathComponent)"
                self.storage.store(from: self.localFile.url, for: storageID)
                self.state.value = .uploaded(file: engagementFile)
            case let .failure(error):
                if let err = error as? CoreSdkClient.SalemoveError {
                    self.state.value = .error(Error(with: err))
                } else {
                    self.state.value = .error(.generic)
                }
            }
        }

        state.value = .uploading(progress: progress)
        environment.uploadFile.uploadFile(
            file,
            progress: onProgress,
            completion: onCompletion
        )
    }

    func removeLocalFile() {
        guard let id = engagementFileInformation?.id else { return }
        storage.removeData(for: id)
    }
}
