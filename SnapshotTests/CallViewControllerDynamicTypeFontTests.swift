@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class CallViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func test_audioCallQueueState_extra3Large() throws {
        let viewController = try CallViewController.mockAudioCallQueueState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_audioCallConnectingState_extra3Large() throws {
        let viewController = try CallViewController.mockAudioCallConnectingState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_audioCallConnectedState_extra3Large() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_mockVideoCallConnectingState_extra3Large() throws {
        let viewController = try CallViewController.mockVideoCallConnectingState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_mockVideoCallQueueState_extra3Large() throws {
        let viewController = try CallViewController.mockVideoCallQueueState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_mockVideoCallConnectedState_extra3Large() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
