@testable import GliaWidgets

extension FileUploader.Environment {
    static let failing = Self(
        uploadFile: .toEngagement(CoreSdkClient.failing.uploadFileToEngagement),
        fileManager: .failing,
        data: FoundationBased.Data.failing,
        date: {
            fail("\(Self.self).date")
            return .mock
        },
        gcd: .mock,
        localFileThumbnailQueue: .mock(),
        uiImage: .mock,
        uuid: {
            fail("\(Self.self)uuid")
            return .mock
        }
    )
}
