@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class CallViewControllerDynamicTypeFontTests: SnapshotTestCase {
    @MainActor
    func test_audioCallQueueState_extra3Large() async throws {
        let viewController = try await CallViewController.mockAudioCallQueueState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_audioCallConnectingState_extra3Large() async throws {
        let viewController = try await CallViewController.mockAudioCallConnectingState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_audioCallConnectedState_extra3Large() async throws {
        let viewController = try await CallViewController.mockAudioCallConnectedState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_mockVideoCallConnectingState_extra3Large() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectingState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_mockVideoCallQueueState_extra3Large() async throws {
        let viewController = try await CallViewController.mockVideoCallQueueState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_mockVideoCallConnectedState_extra3Large() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectedState()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
