import Foundation
import XCTest
@testable import GliaWidgets

final class SecureConversationsConfirmationViewModelTests: XCTestCase {
    typealias ConfirmationViewModel = SecureConversations.ConfirmationViewModel
    var viewModel: ConfirmationViewModel = .mock

    override func setUp() {
        viewModel = .mock
    }
}

// Props
extension SecureConversationsConfirmationViewModelTests {
    func testPropsDoNotGenerateABackButton() {
        let props = viewModel.props().confirmationViewProps.header

        XCTAssertNil(props.backButton)
    }

    func testPropsGenerateCorrectTitle() {
        let title = "Test"
        var style = Theme().secureConversationsConfirmation
        style.headerTitle = title

        viewModel.environment = .init(confirmationStyle: style)

        let props = viewModel.props()
        XCTAssertEqual(props.confirmationViewProps.header.title, title)
    }

    func testPropsGenerateEndButtonWithAccessibilityIdentifier() {
        let props = viewModel.props().confirmationViewProps.header.endButton

        XCTAssertEqual(props.accessibilityIdentifier, "header_end_button")
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

        viewModel.delegate = { event in
            receivedEvent = event
        }

        viewModel.props().confirmationViewProps.header.closeButton.tap()

        switch try XCTUnwrap(receivedEvent) {
            case .closeTapped:
                XCTAssertTrue(true)
            default: XCTFail()
        }
    }

    func testPressingCheckMessagesButtonCallsDelegate() throws {
        var receivedEvent: ConfirmationViewModel.DelegateEvent?

        viewModel.delegate = { event in
            receivedEvent = event
        }

        viewModel.props().confirmationViewProps.checkMessageButtonTap()

        switch try XCTUnwrap(receivedEvent) {
            case .chatTranscriptScreenRequested:
                XCTAssertTrue(true)
            default: XCTFail()
        }
    }

    func testReportingAChangeRendersProps() throws {
        var receivedEvent: ConfirmationViewModel.DelegateEvent?

        viewModel.delegate = { event in
            receivedEvent = event
        }

        viewModel.reportChange()

        switch try XCTUnwrap(receivedEvent) {
            case .renderProps(_):
                XCTAssertTrue(true)
            default: XCTFail()
        }
    }
}
