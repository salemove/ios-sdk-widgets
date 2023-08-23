@testable import GliaWidgets
import XCTest

extension ChatViewModelTests {
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
        var env = ChatViewModel.Environment.mock
        env.uiApplication.canOpenURL = { _ in true }
        env.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        // To ensure `sendSelectedOptionValue` is not called in case of URL Button
        env.sendSelectedOptionValue = { option, _ in
            calls.append(.sendOption(option.text, option.value))
        }
        viewModel = .mock(environment: env)

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
        var env = ChatViewModel.Environment.mock
        // To ensure `open` is not called in case of URL Button
        env.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        env.sendSelectedOptionValue = { option, _ in
            calls.append(.sendOption(option.text, option.value))
        }
        let interactorMock = Interactor.mock()
        interactorMock.state = .engaged(nil)
        viewModel = .mock(interactor: interactorMock, environment: env)

        viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.sendOption("text", "value")])
    }

    func test_gvaPostbackButtonActionTriggersStartEngagement() {
        let option = GvaOption.mock(text: "text", value: "value")
        var calls: [Call] = []
        var env = ChatViewModel.Environment.mock
        // To ensure `open` is not called in case of URL Button
        env.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        // To ensure `sendSelectedOptionValue` is not called in case of Postback Button
        env.sendSelectedOptionValue = { option, _ in
            calls.append(.sendOption(option.text, option.value))
        }
        let interactorMock = Interactor.mock()
        interactorMock.state = .none
        viewModel = .mock(interactor: interactorMock, environment: env)

        viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [])
        XCTAssertEqual(interactorMock.state, .enqueueing)
    }

    func test_broadcastEventAction() {
        let option = GvaOption.mock(text: "text", destinationPdBroadcastEvent: "mock")
        var calls: [Call] = []
        viewModel = .mock(environment: .mock)
        viewModel.engagementAction = { action in
            guard case .showAlert = action else { return }
            calls.append(.showAlert)
        }

        viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.showAlert])
    }
}

private extension ChatViewModelTests {
    enum Call: Equatable {
        case openUrl(String?)
        case sendOption(String?, String?)
        case showAlert

        static func == (lhs: Call, rhs: Call) -> Bool {
            switch (lhs, rhs) {
            case let (.openUrl(lhsUrl), openUrl(rhsUrl)):
                return lhsUrl == rhsUrl
            case let (.sendOption(lhsText, lhsValue), .sendOption(rhsText, rhsValue)):
                return lhsText == rhsText && lhsValue == rhsValue
            case (.showAlert, .showAlert):
                return true
            default:
                return false
            }
        }
    }
}
