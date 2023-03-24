import Foundation

extension FileUpload {
    struct Environment {
        var uploadFile: UploadFile
        var uuid: () -> UUID
    }
}

extension FileUpload.Environment {
    enum UploadFile {
        case toEngagement(CoreSdkClient.UploadFileToEngagement)
        case toSecureMessaging(CoreSdkClient.SecureConversationsUploadFile)
    }
}

extension FileUpload.Environment.UploadFile {
    @discardableResult func uploadFile(
        _ file: CoreSdkClient.EngagementFile,
        progress: CoreSdkClient.EngagementFileProgressBlock?,
        completion: @escaping (Result<CoreSdkClient.EngagementFileInformation, Swift.Error>) -> Void
    ) -> CoreSdkClient.Cancellable? {
        switch self {
        case let .toEngagement(uploadFile):
            uploadFile(file, progress) { fileInfo, error in
                switch (fileInfo, error) {
                case (.none, .none):
                    break
                case let (.none, .some(error)):
                    completion(.failure(error))
                case let (.some(fileInfo), .none):
                    completion(.success(fileInfo))
                case let (.some, .some(error)):
                    completion(.failure(error))
                }
            }
            return nil

        case let .toSecureMessaging(uploadFile):
            return uploadFile(file, progress, completion)
        }
    }
}
