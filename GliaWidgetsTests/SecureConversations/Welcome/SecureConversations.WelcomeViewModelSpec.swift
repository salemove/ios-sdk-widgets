import Foundation
import XCTest
@testable import GliaWidgets

final class SecureConversationsWelcomeViewModelTests: XCTestCase {
    var viewModel: SecureConversations.WelcomeViewModel = .mock

    override func setUp() {
        viewModel = .mock
    }

    func testDelegateGetsCalledOnBackTapped() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case .backTapped:
                isCalled = true
            default: XCTFail()
            }
        }

        viewModel.event(.backTapped)

        XCTAssertEqual(isCalled, true)
    }

    func testDelegateGetsCalledOnCloseTapped() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case .closeTapped:
                isCalled = true
            default: XCTFail()
            }
        }

        viewModel.event(.closeTapped)

        XCTAssertEqual(isCalled, true)
    }
}

// Is attachment available
extension SecureConversationsWelcomeViewModelTests {
    func testIsAttachmentAvailable() {
        var environment: SecureConversations.WelcomeViewModel.Environment = .mock
        environment.fetchSiteConfigurations = { completion in
            let site: CoreSdkClient.Site = try! .mock(
                allowedFileSenders: .init(operator: true, visitor: true)
            )

            completion(.success(site))
        }

        viewModel = .init(environment: environment, availability: .mock)

        XCTAssertTrue(viewModel.isAttachmentsAvailable)
    }

    func testIsAttachmentNotAvailable() {
        var environment: SecureConversations.WelcomeViewModel.Environment = .mock
        environment.fetchSiteConfigurations = { completion in
            let site: CoreSdkClient.Site = try! .mock(
                allowedFileSenders: .init(operator: true, visitor: false)
            )

            completion(.success(site))
        }

        viewModel = .init(environment: environment, availability: .mock)

        XCTAssertFalse(viewModel.isAttachmentsAvailable)
    }

    func testIsAttachmentAvailableFailed() {
        var environment: SecureConversations.WelcomeViewModel.Environment = .mock
        environment.fetchSiteConfigurations = { completion in
            completion(.failure(CoreSdkClient.GliaCoreError(reason: "")))
        }

        var isCalled = false
        var messageAlertConfiguration: MessageAlertConfiguration?

        let delegate: (SecureConversations.WelcomeViewModel.DelegateEvent) -> Void = { event in
            switch event {
            case .showAlert(let configuration, _, _):
                isCalled = true
                messageAlertConfiguration = configuration
            default: break
            }
        }

        viewModel = .init(environment: environment, availability: .mock, delegate: delegate)

        XCTAssertTrue(isCalled)
        XCTAssertTrue(messageAlertConfiguration?.message == self.viewModel.environment.alertConfiguration.unexpectedError.message)
    }

}

// Send message
extension SecureConversationsWelcomeViewModelTests {
    func testSuccessfulMessageSend() {
        var isCalled = false
        self.viewModel.environment.sendSecureMessage = { _, _, _, completion in
            let mockedMessage = CoreSdkClient.Message(
                id: UUID().uuidString,
                content: "Content",
                sender: .mock,
                metadata: nil
            )

            completion(.success(mockedMessage))

            return .mock
        }

        viewModel.delegate = { event in
            switch event {
            case .confirmationScreenRequested:
                isCalled = true
            default: break
            }
        }

        self.viewModel.sendMessageCommand()

        XCTAssertEqual(self.viewModel.sendMessageRequestState, .waiting)
        XCTAssertTrue(isCalled)
    }

    func testFailedMessageSend() {
        var isCalled = false
        var messageAlertConfiguration: MessageAlertConfiguration?
        self.viewModel.environment.sendSecureMessage = { _, _, _, completion in
            completion(.failure(CoreSdkClient.GliaCoreError(reason: "")))

            return .mock
        }

        viewModel.delegate = { event in
            switch event {
            case .showAlert(let configuration, _, _):
                isCalled = true
                messageAlertConfiguration = configuration
            default: break
            }
        }

        self.viewModel.sendMessageCommand()

        XCTAssertEqual(self.viewModel.sendMessageRequestState, .waiting)
        XCTAssertTrue(isCalled)
        XCTAssertTrue(messageAlertConfiguration?.message == self.viewModel.environment.alertConfiguration.unexpectedError.message)
    }
}

// Report change
extension SecureConversationsWelcomeViewModelTests {
    func testReportChangeIsCalledOnMessageTextChange() {
        executeReportChangeEvent { self.viewModel.messageText = "" }
    }

    func testReportChangeIsCalledOnAvailabilityStatusChange() {
        executeReportChangeEvent {
            self.viewModel.availabilityStatus = .unavailable(.unauthenticated)
        }
    }

    func testReportChangeIsCalledOnMessageInputStateChange() {
        executeReportChangeEvent { self.viewModel.messageInputState = .active }

    }

    func testReportChangeIsCalledOnSendMessageRequestStateChange() {
        executeReportChangeEvent { self.viewModel.sendMessageRequestState = .loading }
    }

    private func executeReportChangeEvent(_ event: () -> ()) {

        var count = 0
        viewModel.delegate = { event in
            switch event {
            case .renderProps:
                count += 1
            default: XCTFail()
            }
        }

        event()

        XCTAssertTrue(count == 1)
    }
}
