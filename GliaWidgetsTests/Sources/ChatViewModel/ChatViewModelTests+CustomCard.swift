@testable import GliaWidgets
import XCTest

extension ChatViewModelTests {
    func test_customCardOptionAction() async {
        enum Call: Equatable { case sendOption(String?, String?) }

        let option = HtmlMetadata.Option(text: "text", value: "value")
        var calls: [Call] = []

        var interactorEnv = Interactor.Environment.failing
        // To ensure `sendMessageWithMessagePayload` is not called in case of Postback Button
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _ in
            throw CoreSdkClient.GliaCoreError.mock()
        }
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { _ in }
        interactorEnv.coreSdk.queueForEngagement = { _, _, _ in }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { payload in
            calls.append(.sendOption(payload.content, payload.attachment?.selectedOption))
            return .mock()
        }
        let interactorMock = Interactor.mock(environment: interactorEnv)
        interactorMock.state = .engaged(nil)

        var env = ChatViewModel.Environment.failing()
        env.fileManager.fileExistsAtPath = { _ in true }
        env.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        env.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        env.createFileUploadListModel = { _ in .mock() }
        env.createSendMessagePayload = { content, attachment in
            .mock(content: content, attachment: attachment)
        }
        env.createEntryWidget = { _ in .mock() }
        viewModel = .mock(interactor: interactorMock, environment: env)

        await viewModel.sendSelectedCustomCardOption(
            option,
            for: .init(rawValue: "mock")
        )

        XCTAssertEqual(calls, [.sendOption("text", "value")])
    }
}
