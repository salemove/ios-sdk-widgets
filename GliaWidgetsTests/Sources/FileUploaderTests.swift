@testable import GliaWidgets
import XCTest

class FileUploaderTests: XCTestCase {
    func test_matchingUrlFileUploadsAreUnique() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirUrl = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirUrl]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        var env: FileUploader.Environment = .failing
        env.uploadFileToEngagement = { _, _, _ in }
        env.uuid = { UUID() }
        env.fileManager = fileManager

        let fileUploder = FileUploader(
            maximumUploads: 25,
            environment: env
        )

        let uploadFileUrl: URL = .mock

        guard
            let fileUpload = fileUploder.addUpload(with: uploadFileUrl)
        else {
            XCTFail("Failed to add file uploads")
            return
        }

        // add second upload with same url
        _ = fileUploder.addUpload(with: uploadFileUrl)

        fileUploder.removeUpload(fileUpload)
        XCTAssertFalse(fileUploder.uploads.contains(where: { $0.uuid == fileUpload.uuid }))
    }
}
