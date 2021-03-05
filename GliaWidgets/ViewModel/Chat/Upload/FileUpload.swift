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
        case uploading(url: URL, progress: ValueProvider<Double>)
        case uploaded(url: URL, file: EngagementFileInformation)
        case error(Error)
    }

    let state = ValueProvider<State>(with: .none)

    private let url: URL

    init(with url: URL) {
        self.url = url
    }

    func startUpload() {
        let file = EngagementFile(url: url)
        let progress = ValueProvider<Double>(with: 0)
        let onProgress: EngagementFileProgressBlock = {
            if case .uploading(_, progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }
        let onCompletion: EngagementFileCompletionBlock = { file, error in
            if let file = file {
                self.state.value = .uploaded(url: self.url, file: file)
            } else if let error = error {
                self.state.value = .error(Error(with: error))
            }
        }

        state.value = .uploading(url: url, progress: progress)
        Salemove.sharedInstance.uploadFileToEngagement(file,
                                                       progress: onProgress,
                                                       completion: onCompletion)
    }
}
