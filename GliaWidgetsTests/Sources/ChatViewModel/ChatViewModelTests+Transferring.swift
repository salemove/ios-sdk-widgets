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
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _ in
            throw GliaCoreError.mock()
        }
        interactorEnv.gcd.mainQueue.async = { $0() }
        interactorEnv.coreSdk.queueForEngagement = { _, _, _ in }
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
        env.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
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
