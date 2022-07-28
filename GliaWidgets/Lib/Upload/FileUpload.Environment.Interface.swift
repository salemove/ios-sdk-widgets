import Foundation

extension FileUpload {
    struct Environment {
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var uuid: () -> UUID
    }
}
