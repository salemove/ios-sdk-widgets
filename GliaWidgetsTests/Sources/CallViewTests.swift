import XCTest

@testable import GliaWidgets

class CallViewTests: XCTestCase {
    @MainActor
    func test_setVisitorOnHoldHidesRemoteVideoViewOnVideoCall() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertFalse(view.remoteVideoView.isHidden)
        view.setVisitorOnHold(true)
        XCTAssertTrue(view.remoteVideoView.isHidden)
    }

    @MainActor
    func test_setVisitorOnHoldShowsConnectViewOnVideoCall() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        view.setVisitorOnHold(true)
        XCTAssertTrue(view.state.isOnHold)
    }

    @MainActor
    func test_setVisitorOnHoldShowsBottomLabelOnVideoCall() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView

        XCTAssertTrue(view.bottomLabel.isHidden)
        view.setVisitorOnHold(true)
        XCTAssertFalse(view.bottomLabel.isHidden)
    }

    @MainActor
    func test_setVisitorOnHoldShowsBottomLabelOnAudioCall() async throws {
        let viewController = try await CallViewController.mockAudioCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.bottomLabel.isHidden)
        view.setVisitorOnHold(true)
        XCTAssertFalse(view.bottomLabel.isHidden)
    }

    @MainActor
    func test_toggleVisitorOnHoldHidesBottomLabelOnAudioCall() async throws {
        let viewController = try await CallViewController.mockAudioCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.bottomLabel.isHidden)
        view.setVisitorOnHold(true)
        XCTAssertFalse(view.bottomLabel.isHidden)
        view.setVisitorOnHold(false)
        XCTAssertTrue(view.bottomLabel.isHidden)
    }

    @MainActor
    func test_toggleVisitorOnHoldHidesBottomLabelOnVideoCall() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.bottomLabel.isHidden)
        view.setVisitorOnHold(true)
        XCTAssertFalse(view.bottomLabel.isHidden)
        view.setVisitorOnHold(false)
        XCTAssertTrue(view.bottomLabel.isHidden)
    }

    func test_localVideoSizeReturnsExpectedSizeBasedOnDeviceOrientation() {
        let sideA = 100.0
        let sideB = 50.0
        let screenSize = CGSize(width: sideA, height: sideB)
        let multiplier = CallView.localVideoSideMultiplier
        let sizeForPortrait = CallView.localVideoSize(for: .portrait, from: screenSize)
        XCTAssertEqual(sizeForPortrait, CGSize(width: sideB * multiplier, height: sideA * multiplier))
        let sizeForLandscapeLeft = CallView.localVideoSize(for: .landscapeLeft, from: screenSize)
        XCTAssertEqual(sizeForLandscapeLeft, CGSize(width: sideA * multiplier, height: sideB * multiplier))
        let sizeForLandscapeRight = CallView.localVideoSize(for: .landscapeRight, from: screenSize)
        XCTAssertEqual(sizeForLandscapeRight, CGSize(width: sideA * multiplier, height: sideB * multiplier))
    }
}
