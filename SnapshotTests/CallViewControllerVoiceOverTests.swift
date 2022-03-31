import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class CallViewControllerVoiceOverTests: SnapshotTestCase {
    func test_audioCallQueueState() throws {
        let viewController = try CallViewController.mockAudioCallQueueState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func test_audioCallConnectingState() throws {
        let viewController = try CallViewController.mockAudioCallConnectingState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func test_audioCallConnectedState() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func test_mockVideoCallConnectingState() throws {
        let viewController = try CallViewController.mockVideoCallConnectingState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func test_mockVideoCallQueueState() throws {
        let viewController = try CallViewController.mockVideoCallQueueState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func test_mockVideoCallConnectedState() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

}
