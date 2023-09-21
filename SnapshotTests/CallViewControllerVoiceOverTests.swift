import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class CallViewControllerVoiceOverTests: SnapshotTestCase {
    func test_audioCallQueueState() throws {
        let viewController = try CallViewController.mockAudioCallQueueState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_audioCallConnectingState() throws {
        let viewController = try CallViewController.mockAudioCallConnectingState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_audioCallConnectedState() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_mockVideoCallConnectingState() throws {
        let viewController = try CallViewController.mockVideoCallConnectingState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_mockVideoCallQueueState() throws {
        let viewController = try CallViewController.mockVideoCallQueueState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_mockVideoCallConnectedState() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: nameForDevice()
        )
    }
}
