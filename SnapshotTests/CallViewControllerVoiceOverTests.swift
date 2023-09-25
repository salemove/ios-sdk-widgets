import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class CallViewControllerVoiceOverTests: SnapshotTestCase {
    func test_audioCallQueueState() throws {
        let viewController = try CallViewController.mockAudioCallQueueState()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_audioCallConnectingState() throws {
        let viewController = try CallViewController.mockAudioCallConnectingState()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_audioCallConnectedState() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_mockVideoCallConnectingState() throws {
        let viewController = try CallViewController.mockVideoCallConnectingState()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_mockVideoCallQueueState() throws {
        let viewController = try CallViewController.mockVideoCallQueueState()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_mockVideoCallConnectedState() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        viewController.assertSnapshot(as: .accessibilityImage)
    }
}
