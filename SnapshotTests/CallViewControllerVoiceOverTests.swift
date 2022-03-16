import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class CallViewControllerVoiceOverTests: SnapshotTestCase {
    func _test_audioCallQueueState() throws {
        let viewController = try CallViewController.mockAudioCallQueueState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func _test_audioCallConnectingState() throws {
        let viewController = try CallViewController.mockAudioCallConnectingState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func _test_audioCallConnectedState() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }
}
