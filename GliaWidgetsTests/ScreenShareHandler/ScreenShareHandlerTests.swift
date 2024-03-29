import XCTest
@testable import GliaWidgets
import GliaCoreSDK

final class ScreenShareHandlerTests: XCTestCase {

    func testStatusWhenStateIsNil() {
        let screenShareHandler = ScreenShareHandler.create()
        let state = screenSharingState(status: .sharing)
        screenShareHandler.updateState(state)

        XCTAssertEqual(screenShareHandler.status().value, .started)
        screenShareHandler.updateState(nil)
        XCTAssertEqual(screenShareHandler.status().value, .stopped)
    }

    func testStatusWhenStateIsNotSharing() {
        let screenShareHandler = ScreenShareHandler.create()
        let state = screenSharingState(status: .sharing)
        screenShareHandler.updateState(state)

        XCTAssertEqual(screenShareHandler.status().value, .started)
        screenShareHandler.updateState(nil)
        XCTAssertEqual(screenShareHandler.status().value, .stopped)
    }

    func testStopScreenSharing() {
        let screenShareHandler = ScreenShareHandler.create()
        let state = screenSharingState(status: .sharing)
        screenShareHandler.updateState(state)

        XCTAssertEqual(screenShareHandler.status().value, .started)
        screenShareHandler.stop(nil)
        XCTAssertEqual(screenShareHandler.status().value, .stopped)
    }

    func testStopCompletionIsInvoked() {
        let screenShareHandler = ScreenShareHandler.create()
        var isInvoked = false

        screenShareHandler.stop {
            isInvoked = true
        }
        XCTAssertTrue(isInvoked)
    }

    private func screenSharingState(status: GliaCoreSDK.ScreenSharingStatus) -> CoreSdkClient.VisitorScreenSharingState {
        .init(status: status, localScreen: nil)
    }
}
