@testable import GliaWidgets
import XCTest

extension ChatViewModelTests {
    func test_gvaDeepLinkActionCallsMinimize() async {
        let option: GvaOption = .mock(url: "mock://mock.self", urlTarget: "self")
        var calls: [Call] = []
        viewModel = .mock()
        viewModel.delegate = { event in
            switch event {
            case .minimize:
                calls.append(.minimize)

            default:
                XCTFail("createSendMessagePayload should not be called")
            }
        }

        await viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.minimize])
    }

    func test_gvaDeepLinkActionDoesNotCallMinimize() async {
        let option: GvaOption = .mock(url: "mock://mock.modal", urlTarget: "modal")
        var calls: [Call] = []
        viewModel = .mock()
        viewModel.delegate = { event in
            switch event {
            case .minimize:
                calls.append(.minimize)

            default:
                XCTFail("createSendMessagePayload should not be called")
            }
        }

        await viewModel.gvaOptionAction(for: option)()
        XCTAssertTrue(calls.isEmpty)
    }

    func test_gvaLinkButtonAction() async {
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

        // To ensure `createSendMessagePayload` is not called in case of URL Button
        env.createSendMessagePayload = { _, _ in
            XCTFail("createSendMessagePayload should not be called")
            return .mock()
        }
        viewModel = .mock(environment: env)

        for item in options {
            await viewModel.gvaOptionAction(for: item)()
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

    func test_gvaPostbackButtonAction() async {
        let option = GvaOption.mock(text: "text", value: "value")
        var calls: [Call] = []
        var env = ChatViewModel.Environment.mock
        // To ensure `open` is not called in case of URL Button
        env.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        env.createSendMessagePayload = { content, attachment in
            .mock(content: content, attachment: attachment)
        }
        var interactorEnv = Interactor.Environment.mock
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { payload in
            calls.append(.sendOption(payload.content, payload.attachment?.selectedOption))
            return .mock()
        }
        let interactorMock = Interactor.mock(environment: interactorEnv)
        interactorMock.state = .engaged(nil)

        viewModel = .mock(interactor: interactorMock, environment: env)

        await viewModel.gvaOptionAction(for: option)()
        let expectedCalls: [Call] = [.sendOption("text", "value")]

        XCTAssertEqual(calls, expectedCalls)
    }

    func test_gvaPostbackButtonActionTriggersStartEngagement() async {
        let option = GvaOption.mock(text: "text", value: "value")
        var interactorEnv = Interactor.Environment.failing
        // To ensure `sendMessageWithMessagePayload` is not called in case of Postback Button
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _ in
            throw CoreSdkClient.GliaCoreError.mock()
        }
        interactorEnv.gcd = .live
        interactorEnv.coreSdk.queueForEngagement = { _, _ in .mock }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }

        let interactorMock = Interactor.mock(environment: interactorEnv)
        interactorMock.state = .none

        var env = ChatViewModel.Environment.failing()
        env.fileManager.fileExistsAtPath = { _ in true }
        env.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        env.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        env.createFileUploadListModel = { _ in .mock() }
        env.createSendMessagePayload = { _, _ in .mock() }
        env.createEntryWidget = { _ in .mock() }
        env.fetchSiteConfigurations = { try .mock() }
        viewModel = .mock(interactor: interactorMock, environment: env)
        await viewModel.gvaOptionAction(for: option)()
        viewModel.interactor.state = .enqueueing(.chat)
        XCTAssertEqual(interactorMock.state, .enqueueing(.chat))
    }

    func test_broadcastEventAction() async {
        let option = GvaOption.mock(text: "text", destinationPdBroadcastEvent: "mock")
        var calls: [Call] = []
        viewModel = .mock(environment: .mock)
        viewModel.engagementAction = { action in
            guard case .showAlert = action else { return }
            calls.append(.showAlert)
        }

        await viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.showAlert])
    }

    func test_deliveredGvaMessageStatus() async {
        func checkMessageStatuses(_ statuses: [String?], messagesSectionIndex: Int, testCase: XCTestCase) async {
            statuses.enumerated().forEach {
                let item = viewModel.item(for: $0.offset, in: messagesSectionIndex)
                switch item.kind {
                case let .visitorMessage(_, status):
                    XCTAssertEqual(status, $0.element)
                default:
                    XCTFail("item kind should not be other than visitorMessage")
                }
            }
        }
        var env = ChatViewModel.Environment.mock
        env.gcd = .live
        env.createSendMessagePayload = { content, attachment in
            .mock(
                messageIdSuffix: attachment?.selectedOption ?? "mock",
                content: content,
                attachment: attachment
            )
        }
        var interactorEnv = Interactor.Environment.mock
        interactorEnv.gcd = .live
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { payload in
            return .mock(id: payload.messageId.rawValue)
        }
        let interactorMock = Interactor.mock(environment: interactorEnv)
        interactorMock.state = .engaged(nil)
        let viewModel = ChatViewModel.mock(interactor: interactorMock, environment: env)
        
        let messagesSectionIndex = 3
        let options: [GvaOption] = [
            .mock(value: "mock0"),
            .mock(value: "mock1"),
            .mock(value: "mock2")
        ]

        for item in options {
            await viewModel.gvaOptionAction(for: item)()
        }

        let optionStatuses: [String?] = [nil, nil, "Delivered"]
        await checkMessageStatuses(optionStatuses, messagesSectionIndex: messagesSectionIndex, testCase: self)

        viewModel.event(.messageTextChanged("text"))
        await viewModel.asyncEvent(.sendTapped)

        let statuses: [String?] = [nil, nil, nil, "Delivered"]
        await checkMessageStatuses(statuses, messagesSectionIndex: messagesSectionIndex, testCase: self)
    }
}

private extension ChatViewModelTests {
    enum Call: Equatable {
        case openUrl(String?)
        case sendOption(String?, String?)
        case showAlert
        case minimize
    }
}
