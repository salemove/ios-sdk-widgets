import XCTest

@testable import GliaWidgets

class CallViewTests: XCTestCase {
    func test_setVisitorOnHoldHidesRemoteVideoViewOnVideoCall() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertFalse(view.remoteVideoView.isHidden)
        view.isVisitrOnHold = true
        XCTAssertTrue(view.remoteVideoView.isHidden)
    }
    
    func test_setVisitorOnHoldHidesTopStackViewOnVideoCall() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertFalse(view.topStackView.isHidden)
        view.isVisitrOnHold = true
        XCTAssertTrue(view.topStackView.isHidden)
    }
    
    func test_setVisitorOnHoldShowsConnectViewOnVideoCall() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.connectView.isHidden)
        view.isVisitrOnHold = true
        XCTAssertFalse(view.connectView.isHidden)
    }
    
    func test_setVisitorOnHoldShowsBottomLabelOnVideoCall() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.bottomLabel.isHidden)
        view.isVisitrOnHold = true
        XCTAssertFalse(view.bottomLabel.isHidden)
    }
    
    func test_setVisitorOnHoldShowsBottomLabelOnAudioCall() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.bottomLabel.isHidden)
        view.isVisitrOnHold = true
        XCTAssertFalse(view.bottomLabel.isHidden)
    }
    
    func test_toggleVisitorOnHoldHidesBottomLabelOnAudioCall() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.bottomLabel.isHidden)
        view.isVisitrOnHold = true
        XCTAssertFalse(view.bottomLabel.isHidden)
        view.isVisitrOnHold = false
        XCTAssertTrue(view.bottomLabel.isHidden)
    }
    
    func test_toggleVisitorOnHoldHidesBottomLabelOnVideoCall() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        let view = viewController.view as! CallView
        
        XCTAssertTrue(view.bottomLabel.isHidden)
        view.isVisitrOnHold = true
        XCTAssertFalse(view.bottomLabel.isHidden)
        view.isVisitrOnHold = false
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
