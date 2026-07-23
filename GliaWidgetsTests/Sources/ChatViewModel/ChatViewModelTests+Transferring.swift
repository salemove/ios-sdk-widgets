@testable import GliaWidgets
import XCTest

extension ChatViewModelTests {
    func test_mediaButtonVisibilityDuringTransferring() async throws {
        enum Call: Equatable {
            enum Visibility { case enabled, disabled }
            case updateVisibility(Visibility)
        }

        var calls: [Call] = []

        var interactorEnv = Interactor.Environment.failing
        // To ensure `sendMessageWithMessagePayload` is not called in case of Postback Button
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _ in
            throw CoreSdkClient.GliaCoreError.mock()
        }
        interactorEnv.gcd.mainQueue.async = { $0() }
        interactorEnv.coreSdk.queueForEngagement = { _, _ in .mock }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        var log = interactorEnv.log
        log.prefixedClosure = { _ in log }
        log.infoClosure = { _, _, _, _ in }
        interactorEnv.log = log
        let interactorMock = Interactor.mock(environment: interactorEnv)

        var env = ChatViewModel.Environment.failing()
        env.log = log
        env.fileManager.fileExistsAtPath = { _ in true }
        env.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        env.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        env.createFileUploadListModel = { _ in .mock() }
        env.createSendMessagePayload = { _, _ in .mock() }
        let site: CoreSdkClient.Site = try .mock(
            allowedFileContentTypes: ["image/jpeg"],
            allowedFileSenders: .init(operator: true, visitor: true)
        )
        env.fetchChatHistory = { [.mock()] }
        env.loadChatMessagesFromHistory = { false }
        env.fetchSiteConfigurations = { site }
        env.createEntryWidget = { _ in .mock() }
        interactorMock.setCurrentEngagement(.mock())
        viewModel = .mock(interactor: interactorMock, environment: env)
        viewModel.action = { action in
            switch action {
            case let .setAttachmentButtonEnabling(enabling):
                switch enabling {
                case .enabled:
                    calls.append(.updateVisibility(.enabled))
                case .disabled:
                    calls.append(.updateVisibility(.disabled))
                }
            default:
                break
            }
        }
        await viewModel.start()
        interactorMock.state = .engaged(nil)

        // Will be removed when async state observing is implemented
        await waitUntil {
            calls == [.updateVisibility(.enabled)]
        }
        XCTAssertEqual(
            calls,
            [.updateVisibility(.enabled)]
        )

        interactorMock.notify(.engagementTransferring)
        XCTAssertEqual(
            calls,
            [
                .updateVisibility(.enabled),
                .updateVisibility(.disabled)
            ]
        )

        interactorMock.notify(.engagementTransferred(CoreSdkClient.Operator.mock()))

        XCTAssertEqual(
            calls,
            [
                .updateVisibility(.enabled),
                .updateVisibility(.disabled),
                .updateVisibility(.enabled)
            ]
        )
    }

    func test_multipleTransfersAccumulateOperatorConnectedItems() {
        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.async = { $0() }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { try .mock() }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.infoClosure = { _, _, _, _ in }
        viewModelEnv.log.prefixedClosure = { _ in viewModelEnv.log }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let interactor: Interactor = .mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock())
        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)

        let op1 = CoreSdkClient.Operator.mock(name: "Alice Operator")
        let op2 = CoreSdkClient.Operator.mock(name: "Bob Operator")

        // First transfer: queue → op1 accepts
        interactor.onEngagementTransferring()
        interactor.onEngagementTransfer([op1])

        // Second transfer: op1 → queue → op2 accepts
        interactor.onEngagementTransferring()
        interactor.onEngagementTransfer([op2])

        let operatorConnectedItems = viewModel.messagesSection.items.filter {
            if case .operatorConnected(_, _) = $0.kind { return true }
            return false
        }

        XCTAssertEqual(operatorConnectedItems.count, 2)

        if case let .operatorConnected(name, _) = operatorConnectedItems[0].kind {
            XCTAssertEqual(name, "Alice")
        } else {
            XCTFail("Expected .operatorConnected(name:imageUrl:) for first item")
        }

        if case let .operatorConnected(name, _) = operatorConnectedItems[1].kind {
            XCTAssertEqual(name, "Bob")
        } else {
            XCTFail("Expected .operatorConnected(name:imageUrl:) for second item")
        }

        XCTAssertFalse(
            viewModel.messagesSection.items.contains(where: { $0.kind == .transferring }),
            "No transferring items should remain after transfer completes"
        )
    }
}
