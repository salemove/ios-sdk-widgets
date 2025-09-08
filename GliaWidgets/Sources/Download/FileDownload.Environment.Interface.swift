import Foundation

extension FileDownload {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.SecureConversations.DownloadFile
        var fileManager: FoundationBased.FileManager
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
    }
}

extension FileDownload.Environment {
    enum FetchFile {
        case fromEngagement(CoreSdkClient.FetchFile)
        case fromSecureMessaging(CoreSdkClient.SecureConversations.DownloadFile)
    }
}
extension FileDownload.Environment.FetchFile {
    @discardableResult
    func startWithFile(
        _ file: CoreSdkClient.EngagementFile,
        progress: @escaping CoreSdkClient.EngagementFileProgressBlock
    ) async throws -> CoreSdkClient.EngagementFileData {
        switch self {
        case let .fromSecureMessaging(fetch):
            return try await fetch(file, progress)
        case let .fromEngagement(fetch):
            return try await fetch(file, progress)
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
        var downloadSecureFile: CoreSdkClient.SecureConversations.DownloadFile
    }
}

extension FileDownload.Environment.FetchFile.Environment {
    static func create(with environment: FileDownload.Environment) -> Self {
        .init(
            fetchFile: environment.fetchFile,
            downloadSecureFile: environment.downloadSecureFile
        )
    }
}
