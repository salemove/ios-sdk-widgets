extension FileDownload {
    struct Environment {
        var fetchFile: FetchFile
        var fileManager: FoundationBased.FileManager
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
    }
}

extension FileDownload.Environment {
    enum FetchFile {
        case fromEngagement(CoreSdkClient.FetchFile)
        case fromSecureMessaging(CoreSdkClient.DownloadSecureFile)
    }
}
extension FileDownload.Environment.FetchFile {
    @discardableResult
    func startWithFile(
        _ file: CoreSdkClient.EngagementFile,
        progress: @escaping CoreSdkClient.EngagementFileProgressBlock,
        completion: @escaping (Result<CoreSdkClient.EngagementFileData, Error>) -> Void) -> CoreSdkClient.Salemove.Cancellable? {
            switch self {
            case let .fromSecureMessaging(fetch):
                return fetch(file, progress, completion)
            case let .fromEngagement(fetch):
                fetch(file, progress) { data, error in
                    switch (data, error) {
                    case (.none, .none):
                        break
                    case let (_, .some(error)):
                        completion(.failure(error))
                    case let (.some(fileData), .none):
                        completion(.success(fileData))
                    }
                }

                return nil
            }
        }
}
