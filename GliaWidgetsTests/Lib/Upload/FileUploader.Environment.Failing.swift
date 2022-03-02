@testable import GliaWidgets

extension FileUploader.Environment {
    static let failing = Self(
        uploadFileToEngagement: CoreSdkClient.failing.uploadFileToEngagement,
        fileManager: .failing,
        data: FoundationBased.Data.failing,
        date: {
            fail("\(Self.self).date")
            return .mock
        },
        uuid: {
            fail("\(Self.self)uuid")
            return .mock
        }
    )
}
