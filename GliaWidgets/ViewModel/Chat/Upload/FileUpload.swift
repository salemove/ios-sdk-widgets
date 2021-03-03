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
        case uploading(progress: ValueProvider<Double>)
        case uploaded(EngagementFileInformation)
        case error(Error)
    }

    let state = ValueProvider<State>(with: .none)

    private let url: URL

    init(with url: URL) {
        self.url = url
    }

    func startUpload() {
        let file = EngagementFile(url: url)
        let onProgress: EngagementFileProgressBlock = {
            if case .uploading(progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }

        let progress = ValueProvider<Double>(with: 0)
        state.value = .uploading(progress: progress)

        let onCompletion: EngagementFileCompletionBlock = { file, error in
            if let file = file {
                self.state.value = .uploaded(file)
            } else if let error = error {
                self.state.value = .error(Error(with: error))
            }
        }

        Salemove.sharedInstance.uploadFileToEngagement(file,
                                                       progress: onProgress,
                                                       completion: onCompletion)
    }
}
