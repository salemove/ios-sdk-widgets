@testable import GliaWidgets
import XCTest

extension SecureConversationsTranscriptModelTests {
    func test_handleUrlWithPhoneOpensURLWithUIApplication() throws {
        var calls: [Call] = []
        let viewModel = createViewModel()
        viewModel.environment.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return true
        }
        viewModel.environment.uiApplication.open = { url in
            calls.append(.open(url))
        }

        let telUrl = try XCTUnwrap(URL(string: "tel:12345678"))
        viewModel.linkTapped(telUrl)

        XCTAssertEqual(calls, [.canOpen(telUrl), .open(telUrl)])
    }

    func test_handleUrlWithEmailOpensURLWithUIApplication() throws {
        var calls: [Call] = []
        let viewModel = createViewModel()
        viewModel.environment.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return true
        }
        viewModel.environment.uiApplication.open = { url in
            calls.append(.open(url))
        }

        let mailUrl = try XCTUnwrap(URL(string: "mailto:mock@mock.mock"))
        viewModel.linkTapped(mailUrl)

        XCTAssertEqual(calls, [.canOpen(mailUrl), .open(mailUrl)])
    }

    func test_handleUrlWithLinkOpensCalsLinkTapped() throws {
        var calls: [Call] = []
        let viewModel = createViewModel()
        viewModel.environment.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return true
        }
        viewModel.environment.uiApplication.open = { url in
            calls.append(.open(url))
        }

        let linkUrl = try XCTUnwrap(URL(string: "https://mock.mock"))
        viewModel.linkTapped(linkUrl)

        XCTAssertEqual(calls, [.canOpen(linkUrl), .open(linkUrl)])
    }

    func test_handleUrlWithRandomScheme() throws {
        enum Call: Equatable { case canOpen(URL), open(URL) }

        var calls: [Call] = []
        let viewModel = createViewModel()
        viewModel.environment.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return true
        }
        viewModel.environment.uiApplication.open = { url in
            calls.append(.open(url))
        }

        let mockUrl = try XCTUnwrap(URL(string: "mock://mock"))
        viewModel.linkTapped(mockUrl)

        XCTAssertEqual(calls, [.canOpen(mockUrl), .open(mockUrl)])
    }
    
    func test_handleUrlThatCanNotBeOpenedShouldLog() throws {
        enum Call: Equatable { case canOpen(URL), log }
        var calls: [Call] = []
        let viewModel = createViewModel()
        viewModel.environment.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return false
        }
        viewModel.environment.log.prefixedClosure = { prefix in
            calls.append(.log)
            return .mock
        }

        let linkUrl = try XCTUnwrap(URL(string: "https://mock.mock"))
        viewModel.linkTapped(linkUrl)

        XCTAssertEqual(calls, [.canOpen(linkUrl), .log])
    }
}

private extension SecureConversationsTranscriptModelTests {
    enum Call: Equatable { case canOpen(URL), open(URL) }

    func createViewModel() -> TranscriptModel {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback([], nil) }
        modelEnv.maximumUploads = { 2 }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock()
        )

        return TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            interactor: .failing
        )
    }
}
