@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class CallViewControllerLayoutTests: SnapshotTestCase {
    @MainActor
    func test_audioCallQueueState() async throws {
        let viewController = try await CallViewController.mockAudioCallQueueState()
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    @MainActor
    func test_audioCallConnectingState() async throws {
        let viewController = try await CallViewController.mockAudioCallConnectingState()
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    @MainActor
    func test_audioCallConnectedState() async throws {
        let viewController = try await CallViewController.mockAudioCallConnectedState()
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    @MainActor
    func test_mockVideoCallConnectingState() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectingState()
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    @MainActor
    func test_mockVideoCallQueueState() async throws {
        let viewController = try await CallViewController.mockVideoCallQueueState()
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    @MainActor
    func test_mockVideoCallConnectedState() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectedState()
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    @MainActor
    func test_mockVideoCallConnectedStateWithFlipToBackCameraButton() async throws {
        let viewController = try await CallViewController.mockVideoCallConnectedStateWithFlipToBackCameraButton()
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }
}
