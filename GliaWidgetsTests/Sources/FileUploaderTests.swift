@testable import GliaWidgets
import XCTest

class FileUploaderTests: XCTestCase {
    @MainActor
    func test_uploadCompletionUpdatesStorageOnMainThread() async {
        let stored = expectation(description: "Uploaded file stored")
        var fileManager = FoundationBased.FileManager.mock
        fileManager.copyItemAtPath = { _, _ in
            XCTAssertTrue(Thread.isMainThread)
            stored.fulfill()
        }
        let storage = FileSystemStorage.mock(environment: .mock(fileManager: fileManager))
        var environment = FileUpload.Environment.mock
        environment.uploadFile = .toEngagement { _, _ in try .mock() }
        let upload = FileUpload.mock(storage: storage, environment: environment)

        upload.startUpload()

        await fulfillment(of: [stored], timeout: 1)
        withExtendedLifetime(upload) {}
    }

    func test_matchingUrlFileUploadsAreUnique() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirUrl = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirUrl]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        var env: FileUploader.Environment = .failing
        env.uploadFile = .mock
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
