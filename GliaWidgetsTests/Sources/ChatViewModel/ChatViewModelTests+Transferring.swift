@testable import GliaWidgets
import GliaCoreSDK
import XCTest

extension ChatViewModelTests {
    func test_mediaButtonVisibilityDuringTransferring() throws {
        enum Call: Equatable {
            enum Visibility { case enabled, disabled }
            case updateVisibility(Visibility)
        }

        var calls: [Call] = []

        var interactorEnv = Interactor.Environment.failing
        // To ensure `sendMessageWithMessagePayload` is not called in case of Postback Button
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _, _ in
            XCTFail("createSendMessagePayload should not be called")
        }
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        interactorEnv.coreSdk.queueForEngagement = { _, _ in }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        let interactorMock = Interactor.mock(environment: interactorEnv)
        interactorMock.isConfigurationPerformed = true

        var env = ChatViewModel.Environment.failing()
        env.fileManager.fileExistsAtPath = { _ in true }
        env.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        env.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        env.createFileUploadListModel = { _ in .mock() }
        env.createSendMessagePayload = { _, _ in .mock() }
        let site: CoreSdkClient.Site = try .mock(
            allowedFileSenders: .init(operator: true, visitor: true)
        )
        env.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        env.getCurrentEngagement = { .mock() }
        viewModel = .mock(interactor: interactorMock, environment: env)

        viewModel.action = { action in
            switch action {
            case let .setAttachmentButtonVisibility(visibility):
                switch visibility {
                case .enabled:
                    calls.append(.updateVisibility(.enabled))
                case .disabled:
                    calls.append(.updateVisibility(.disabled))
                }
            default:
                break
            }
        }
        interactorMock.state = .engaged(nil)
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

        interactorMock.notify(.engagementTransferred(GliaCoreSDK.Operator.mock()))

        XCTAssertEqual(
            calls,
            [
                .updateVisibility(.enabled),
                .updateVisibility(.disabled),
                .updateVisibility(.enabled)
            ]
        )
    }
}
