@testable import GliaWidgets
import XCTest
class FileSystemStorageTests: XCTestCase {
    func test_init_createsDirectoryWithExpectedParams() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirURL = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirURL]
        }

        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { url, createIntermadiate, attribs in
            XCTAssertEqual(url, expectedDirURL)
            XCTAssertTrue(createIntermadiate)
            XCTAssertNil(attribs)
        }
        var env = FileSystemStorage.Environment.failing
        env.fileManager = fileManager
        _ = FileSystemStorage(
            directory: .documents(fileManager),
            environment: env
        )
    }

    func test_deinit_deletesFilesIfExpired() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirURL = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirURL]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let expectedFile = "file.mock"
        var contents = [expectedFile]
        fileManager.contentsOfDirectoryAtPath = { _ in
            return contents
        }
        let fileDate = Date(timeIntervalSince1970: .zero)
        let nowDate = Date(timeIntervalSince1970: 1)
        fileManager.attributesOfItemAtPath = { _ in
            [FileAttributeKey.creationDate: fileDate]
        }

        fileManager.removeItemAtPath = { item in
            XCTAssertEqual(item, expectedDirURL.appendingPathComponent(expectedFile).path)
            contents.removeLast()
        }

        var env = FileSystemStorage.Environment.failing
        env.fileManager = fileManager
        env.date = { nowDate }

        var fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            expiration: .seconds(.zero),
            environment: env
        )

        fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            environment: env
        )
        _ = fileStorage
        XCTAssertTrue(contents.isEmpty)
    }

    func test_deinit_leavesFilesUntouchedIfNotExpired() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirURL = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirURL]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let expectedFile = "file.mock"
        let contents = [expectedFile]
        fileManager.contentsOfDirectoryAtPath = { _ in
            return contents
        }
        let fileDate = Date(timeIntervalSince1970: .zero)
        let nowDate = Date(timeIntervalSince1970: .zero)
        fileManager.attributesOfItemAtPath = { _ in
            [FileAttributeKey.creationDate: fileDate]
        }

        var env = FileSystemStorage.Environment.failing
        env.fileManager = fileManager
        env.date = { nowDate }

        var fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            expiration: .seconds(.zero),
            environment: env
        )

        fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            environment: env
        )
        _ = fileStorage
    }

    func test_storeDataForKeyRemovesExistingFileAndWriteDataToFileUrl() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirURL = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirURL]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        var env = FileSystemStorage.Environment.failing
        env.fileManager = fileManager

        let fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            expiration: .none,
            environment: env
        )

        let expectedKey = "mockKey"
        fileStorage.environment.fileManager = .failing
        var resultPath = ""
        fileStorage.environment.fileManager.fileExistsAtPath = { path in
            resultPath = path
            return true
        }

        var resultUrl = URL.mock
        fileStorage.environment.fileManager.removeItemAtUrl = { url in
            resultUrl = url
        }

        var resultWriteUrl = URL.mock
        fileStorage.environment.data.writeDataToUrl = { _, url in
            resultWriteUrl = url
        }

        fileStorage.store(.mock, for: expectedKey)

        XCTAssertEqual(resultPath, expectedDirURL.appendingPathComponent(expectedKey).path)
        XCTAssertEqual(resultUrl, expectedDirURL.appendingPathComponent(expectedKey))
        XCTAssertEqual(resultWriteUrl, expectedDirURL.appendingPathComponent(expectedKey))
    }

    func test_storeDataForKeyCreatesDirectoryForKeyIfNeeded() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirURL = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirURL]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        var env = FileSystemStorage.Environment.failing
        env.fileManager = fileManager

        let fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            expiration: .none,
            environment: env
        )

        let expectedKey = "mockKey"
        fileStorage.environment.fileManager = .failing
        fileStorage.environment.fileManager.fileExistsAtPath = { _ in
            return false
        }

        var expectedCreateDirUrl = URL.mockFilePath
        var createIntermediateDirs = false
        var fileAttribs: [FileAttributeKey: Any]? = [:]

        fileStorage.environment.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { url, shouldCreate, attribs in
            expectedCreateDirUrl = url
            createIntermediateDirs = shouldCreate
            fileAttribs = attribs
        }

        fileStorage.environment.fileManager.removeItemAtUrl = { _ in }
        fileStorage.environment.data.writeDataToUrl = { _, _ in }
        fileStorage.store(.mock, for: expectedKey)
        XCTAssertEqual(expectedCreateDirUrl, expectedDirURL.appendingPathComponent(expectedKey))
        XCTAssertTrue(createIntermediateDirs)
        XCTAssertNil(fileAttribs)
    }

    func test_storeFromUrlForKeyRemovesExistingFileAndCopiesFileToPath() {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirURL = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirURL]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        var env = FileSystemStorage.Environment.failing
        env.fileManager = fileManager

        let fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            expiration: .none,
            environment: env
        )

        fileStorage.environment.fileManager = .failing
        fileStorage.environment.fileManager.fileExistsAtPath = { _ in true }
        let expectedKey = "mockFileKey"
        let expectedFileUrl = expectedDirURL.appendingPathComponent(expectedKey)
        var copiedPathResult = ""
        var removedUrlResult = URL.mockFilePath
        fileStorage.environment.fileManager.removeItemAtUrl = { url in
            removedUrlResult = url
        }

        fileStorage.environment.fileManager.copyItemAtPath = { _, toPath in
            copiedPathResult = toPath
        }
        fileStorage.store(from: expectedFileUrl, for: expectedKey)

        XCTAssertEqual(copiedPathResult, expectedFileUrl.path)
        XCTAssertEqual(removedUrlResult, expectedFileUrl)
    }

    func test_storeFromUrlForKeyCreatesIntermediateDirsForFilePathIfNeeded () {
        var fileManager = FoundationBased.FileManager.failing
        let expectedDirURL = URL.mockFilePath
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [expectedDirURL]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        var env = FileSystemStorage.Environment.failing
        env.fileManager = fileManager

        let fileStorage = FileSystemStorage(
            directory: .documents(fileManager),
            expiration: .none,
            environment: env
        )

        fileStorage.environment.fileManager = .failing
        fileStorage.environment.fileManager.fileExistsAtPath = { _ in false }
        let expectedKey = "mockFileKey"
        let expectedFileUrl = expectedDirURL.appendingPathComponent(expectedKey)
        var copiedPathResult = ""
        var resultCreateDirUrl = URL.mockFilePath
        var shouldCreateIntemediate = false
        var fileAttribs: [FileAttributeKey: Any]? = [:]
        fileStorage.environment.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { url, shouldCreate, attribs in
            resultCreateDirUrl = url
            shouldCreateIntemediate = shouldCreate
            fileAttribs = attribs
        }

        fileStorage.environment.fileManager.copyItemAtPath = { _, toPath in
            copiedPathResult = toPath
        }
        fileStorage.store(from: expectedFileUrl, for: expectedKey)

        XCTAssertEqual(copiedPathResult, expectedFileUrl.path)
        XCTAssertEqual(resultCreateDirUrl, expectedFileUrl)
        XCTAssertTrue(shouldCreateIntemediate)
        XCTAssertNil(fileAttribs)
    }
}
