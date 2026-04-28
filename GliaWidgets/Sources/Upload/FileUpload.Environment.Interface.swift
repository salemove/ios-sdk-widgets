import Foundation
import GliaCoreSDK

extension FileUpload {
    struct Environment {
        var uploadFile: UploadFile
        var uuid: () -> UUID
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension FileUpload.Environment {
    enum UploadFile {
        case toEngagement(CoreSdkClient.UploadFileToEngagement)
        case toSecureMessaging(CoreSdkClient.SecureConversations.UploadFile)
    }

    static func create(with environment: FileUploader.Environment) -> Self {
        .init(
            uploadFile: environment.uploadFile,
            uuid: environment.uuid
        )
    }
}

extension FileUpload.Environment.UploadFile {
    func uploadFile(
        _ file: CoreSdkClient.EngagementFile,
        progress: CoreSdkClient.EngagementFileProgressBlock?
    ) async throws -> CoreSdkClient.EngagementFileInformation {
        switch self {
        case let .toEngagement(uploadFile):
            return try await uploadFile(file, progress)

        case let .toSecureMessaging(uploadFile):
            return try await uploadFile(file, progress)
        }
    }
}
