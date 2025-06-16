@testable import GliaWidgets
import XCTest

final class EngagementViewModelTests: XCTestCase {
    func testHandleScreenSharingStatusShowsEndScreenSharingButton() {
        let viewModel = EngagementViewModel(
            interactor: .failing,
            screenShareHandler: .mock, 
            replaceExistingEnqueueing: false,
            environment: .mock
        )
        enum Call { case showEndScreenShareButton }
        var calls: [Call] = []
        viewModel.engagementAction = { action in
            switch action {
            case .showEndScreenShareButton:
                calls.append(.showEndScreenShareButton)
            default:
                XCTFail("Action should be `.showEndScreenShareButton`")
            }
        }
        viewModel.handleScreenSharingStatus(.started)

        XCTAssertEqual(calls, [.showEndScreenShareButton])
    }

    func testHandleScreenSharingStatusShowsEndButton() {
        let viewModel = EngagementViewModel(
            interactor: .failing,
            screenShareHandler: .mock, 
            replaceExistingEnqueueing: false,
            environment: .mock
        )
        enum Call { case showEndButton }
        var calls: [Call] = []
        viewModel.activeEngagement = .mock()
        viewModel.engagementAction = { action in
            switch action {
            case .showEndButton:
                calls.append(.showEndButton)
            default:
                XCTFail("Action should be `.showEndButton`")
            }
        }
        viewModel.handleScreenSharingStatus(.stopped)

        XCTAssertEqual(calls, [.showEndButton])
    }

    func testHandleScreenSharingStatusShowsCloseButton() {
        let interactor = Interactor.failing
        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))
        let viewModel = EngagementViewModel(
            interactor: interactor,
            screenShareHandler: .mock,
            replaceExistingEnqueueing: false,
            environment: .mock
        )
        enum Call { case showCloseButton }
        var calls: [Call] = []
        viewModel.engagementAction = { action in
            switch action {
            case .showCloseButton:
                calls.append(.showCloseButton)
            default:
                XCTFail("Action should be `.showCloseButton`")
            }
        }
        viewModel.handleScreenSharingStatus(.stopped)

        XCTAssertEqual(calls, [.showCloseButton])
    }
}
