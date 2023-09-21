@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class CallViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func test_audioCallQueueState_extra3Large() throws {
        let viewController = try CallViewController.mockAudioCallQueueState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_audioCallConnectingState_extra3Large() throws {
        let viewController = try CallViewController.mockAudioCallConnectingState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_audioCallConnectedState_extra3Large() throws {
        let viewController = try CallViewController.mockAudioCallConnectedState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_mockVideoCallConnectingState_extra3Large() throws {
        let viewController = try CallViewController.mockVideoCallConnectingState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_mockVideoCallQueueState_extra3Large() throws {
        let viewController = try CallViewController.mockVideoCallQueueState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_mockVideoCallConnectedState_extra3Large() throws {
        let viewController = try CallViewController.mockVideoCallConnectedState()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }
}
