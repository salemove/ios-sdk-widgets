import Foundation
import XCTest
@testable import GliaWidgets

final class SecureConversationsConfirmationViewModelTests: XCTestCase {
    typealias ConfirmationViewModel = SecureConversations.ConfirmationViewSwiftUI.Model

    var viewModel: ConfirmationViewModel = .init(
        environment: .init(
            orientationManager: .mock(), uiApplication: .mock
        ),
        style: Theme().defaultSecureConversationsConfirmationStyle,
        delegate: nil
    )
}

// Props
extension SecureConversationsConfirmationViewModelTests {
    func testPropsDoNotGenerateABackButton() {
        let backButton = viewModel.style.header.backButton

        XCTAssertNil(backButton)
    }

    func testPropsGenerateCorrectTitle() {
        let title = "Test"
        viewModel = .init(
            environment: .init(
                orientationManager: .mock(), uiApplication: .mock
            ),
            style: .mock(title: title),
            delegate: nil
        )
        XCTAssertEqual(viewModel.style.headerTitle, title)
    }
}

// Delegate
extension SecureConversationsConfirmationViewModelTests {
    func testSendingCloseButtonEventCallsDelegate() throws {
        var receivedEvent: ConfirmationViewModel.DelegateEvent?

        viewModel.delegate = { event in
            receivedEvent = event
        }

        viewModel.event(.closeTapped)

        switch try XCTUnwrap(receivedEvent) {
            case .closeTapped:
                XCTAssertTrue(true)
            default: XCTFail()
        }
    }

    func testPressingCloseButtonCallsDelegate() throws {
        var receivedEvent: ConfirmationViewModel.DelegateEvent?

        viewModel = .init(
            environment: .init(
                orientationManager: .mock(), uiApplication: .mock
            ),
            style: .mock(),
            delegate: { event in
                receivedEvent = event
            }
        )
        viewModel.delegate?(.closeTapped)

        switch try XCTUnwrap(receivedEvent) {
            case .closeTapped:
                XCTAssertTrue(true)
            default: XCTFail()
        }
    }

    func testPressingCheckMessagesButtonCallsDelegate() throws {
        var receivedEvent: ConfirmationViewModel.DelegateEvent?

        viewModel = .init(
            environment: .init(
                orientationManager: .mock(), uiApplication: .mock
            ),
            style: .mock(),
            delegate: { event in
                receivedEvent = event
            }
        )
        viewModel.delegate?(.chatTranscriptScreenRequested)

        switch try XCTUnwrap(receivedEvent) {
            case .chatTranscriptScreenRequested:
                XCTAssertTrue(true)
            default: XCTFail()
        }
    }
}
