import Foundation

extension FileDownload {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var fileManager: FoundationBased.FileManager
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
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
        completion: @escaping (Result<CoreSdkClient.EngagementFileData, Error>) -> Void
    ) -> CoreSdkClient.Salemove.Cancellable? {
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

    static func fetchForEngagementFile(
        _ file: CoreSdkClient.EngagementFile,
        environment: Environment
    ) -> FileDownload.Environment.FetchFile {
        guard let components = file.url
            .flatMap({ url in URLComponents(url: url, resolvingAgainstBaseURL: false) }),
            components.path.starts(with: "/messaging/files/") else {
            return .fromEngagement(environment.fetchFile)
        }

        return .fromSecureMessaging(environment.downloadSecureFile)
    }

    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
    }
}
