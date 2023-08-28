@testable import GliaWidgets
import XCTest

extension SecureConversationsTranscriptModelTests {
    func test_gvaLinkButtonAction() {
        let options: [GvaOption] = [
            .mock(url: "http://mock.mock"),
            .mock(url: "https://mock.mock"),
            .mock(url: "mock://mock.self", urlTarget: "self"),
            .mock(url: "mock://mock.modal", urlTarget: "modal"),
            .mock(url: "mock://mock", urlTarget: "mock"),
            .mock(url: "mailto:mock@mock.mock"),
            .mock(url: "tel:12345678")
        ]
        var calls: [Call] = []

        let viewModel = createViewModel()
        viewModel.environment.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        viewModel.environment.sendSecureMessage = { message, attachment, _, _ in
            calls.append(.sendOption(message, attachment?.selectedOption))
            return .mock
        }
        options.forEach {
            viewModel.gvaOptionAction(for: $0)()
        }

        let expectedResult: [Call] = [
            .openUrl("http://mock.mock"),
            .openUrl("https://mock.mock"),
            .openUrl("mock://mock.self"),
            .openUrl("mock://mock.modal"),
            .openUrl("mailto:mock@mock.mock"),
            .openUrl("tel:12345678")
        ]
        XCTAssertEqual(calls, expectedResult)
    }

    func test_gvaPostbackButtonAction() {
        let option = GvaOption.mock(text: "text", value: "value")
        var calls: [Call] = []
        let viewModel = createViewModel()
        // To ensure `open` is not called in case of URL Button
        viewModel.environment.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        viewModel.environment.sendSecureMessage = { message, attachment, _, _ in
            calls.append(.sendOption(message, attachment?.selectedOption))
            return .mock
        }
        viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.sendOption("text", "value")])
    }

    func test_broadcastEventAction() {
        let option = GvaOption.mock(text: "text", destinationPdBroadcastEvent: "mock")
        var calls: [Call] = []
        let viewModel = createViewModel()
        viewModel.engagementAction = { action in
            guard case .showAlert = action else { return }
            calls.append(.showAlert)
        }

        viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.showAlert])
    }
}

private extension SecureConversationsTranscriptModelTests {
    enum Call: Equatable {
        case openUrl(String?)
        case sendOption(String?, String?)
        case showAlert
    }

    func createViewModel() -> TranscriptModel {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback([], nil) }
        modelEnv.uiApplication.canOpenURL = { _ in true }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        return TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
    }
}
