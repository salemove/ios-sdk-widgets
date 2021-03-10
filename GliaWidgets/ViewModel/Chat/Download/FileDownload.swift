import SalemoveSDK

class FileDownload {
    enum Error {
        case network
        case generic
        case missingFileID

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
        case downloading(file: EngagementFile, progress: ValueProvider<Double>)
        case downloaded(file: EngagementFile, data: EngagementFileData)
        case error(Error)
    }

    var engagementFileData: EngagementFileData? {
        switch state.value {
        case .downloaded(file: _, data: let data):
            return data
        default:
            return nil
        }
    }

    let state = ValueProvider<State>(with: .none)

    private let file: EngagementFile

    init(with file: EngagementFile) {
        self.file = file
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
                self.state.value = .downloaded(file: self.file, data: data)
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
