class FileDownload {
    enum Error {
        case network
        case generic
        case missingFileURL
        case deleted

        init(with error: CoreSdkClient.SalemoveError) {
            switch error.error {
            case let genericError as CoreSdkClient.GeneralError:
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

        var accessibilityString: String {
            switch self {
            case .none: return "download"
            case .downloading: return "downloading"
            case .downloaded: return "downloaded"
            case .error: return "error"
            }
        }
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
    private let environment: Environment

    init(with file: ChatEngagementFile, storage: DataStorage, environment: Environment) {
        self.file = file
        self.storage = storage
        self.environment = environment

        if file.isDeleted == true {
            state.value = .error(.deleted)
        } else if let storageID = storageID, storage.hasData(for: storageID) {
            let url = storage.url(for: storageID)
            let localFile = LocalFile(
                with: url,
                environment: .create(with: environment)
            )
            state.value = .downloaded(localFile)
        }
    }

    @MainActor
    func startDownload() async {
        guard let fileUrl = file.url else {
            state.value = .error(.missingFileURL)
            return
        }

        let fetchFile = Environment.FetchFile.fetchForEngagementFile(
            CoreSdkClient.EngagementFile(url: fileUrl),
            environment: .create(with: environment)
        )

        let engagementFile: CoreSdkClient.EngagementFile

        switch fetchFile {
        case .fromEngagement:
            engagementFile = CoreSdkClient.EngagementFile(url: fileUrl)
        case .fromSecureMessaging:
            engagementFile = file.id.map(CoreSdkClient.EngagementFile.init(id:)) ?? CoreSdkClient.EngagementFile(url: fileUrl)
        }

        let progress = ObservableValue<Double>(with: 0)
        let onProgress: CoreSdkClient.EngagementFileProgressBlock = {
            if case .downloading(progress: let progress) = self.state.value {
                progress.value = $0.fractionCompleted
            }
        }

        state.value = .downloading(progress: progress)

        do {
            let fileData = try await fetchFile.startWithFile(engagementFile, progress: onProgress)
            guard let storageID else { return }
            let url = storage.url(for: storageID)
            let file = LocalFile(
                with: url,
                environment: .create(with: environment)
            )
            storage.store(fileData.data, for: storageID)
            state.value = .downloaded(file)
        } catch let error as CoreSdkClient.GliaCoreError {
            state.value = .error(Error(with: error))
        } catch {
            state.value = .error(.generic)
        }
    }
}

extension FileDownload {
    struct AccessibilityProperties {
        var value: String?
    }

    var accessibilityProperties: AccessibilityProperties {
        .init(value: file.fileInfoString)
    }
}
