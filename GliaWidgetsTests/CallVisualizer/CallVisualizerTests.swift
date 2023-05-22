import XCTest
import GliaCoreSDK
@testable import GliaWidgets

final class CallVisualizerTests: XCTestCase {
    private enum Call { case updateState }
    private var calls: [Call] = []

    override func setUp() {
        super.setUp()
        calls.removeAll()
    }

    func testScreenSharingStateChanged() {
        var screenShareHandlerMock = ScreenShareHandler.mock
        screenShareHandlerMock.updateState = { _ in
            self.calls.append(.updateState)
        }
        var environmentMock = CallVisualizer.Environment.mock
        environmentMock.screenShareHandler = screenShareHandlerMock
        environmentMock.getCurrentEngagement = {
            .init(id: "", engagedOperator: nil, source: .callVisualizer, fetchSurvey: { _, _ in })
        }
        let interactorMock = Interactor.mock()
        environmentMock.interactorProviding = { interactorMock }
        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        interactorMock.onVisitorScreenSharingStateChange(
            screenSharingState(status: .sharing),
            nil
        )

        XCTAssertEqual(calls, [.updateState])
    }

    func testHandlingInteractorEventWhenEngagementIsNil() {
        var screenShareHandlerMock = ScreenShareHandler.mock
        screenShareHandlerMock.updateState = { _ in
            self.calls.append(.updateState)
        }
        var environmentMock = CallVisualizer.Environment.mock
        environmentMock.screenShareHandler = screenShareHandlerMock
        environmentMock.getCurrentEngagement = { nil }

        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        environmentMock.interactorProviding()?.onVisitorScreenSharingStateChange(
            screenSharingState(status: .sharing),
            nil
        )

        XCTAssertEqual(calls, [])
    }

    func testHandlingInteractorEventWhenEngagementIsLive() {
        enum Call { case updateState }
        var calls: [Call] = []
        var screenShareHandlerMock = ScreenShareHandler.mock
        screenShareHandlerMock.updateState = { _ in
            calls.append(.updateState)
        }
        var environmentMock = CallVisualizer.Environment.mock
        environmentMock.screenShareHandler = screenShareHandlerMock
        environmentMock.getCurrentEngagement = {
            .init(id: "", engagedOperator: nil, source: .coreEngagement, fetchSurvey: { _, _ in })
        }

        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        environmentMock.interactorProviding()?.onVisitorScreenSharingStateChange(
            screenSharingState(status: .sharing),
            nil
        )

        XCTAssertEqual(calls, [])
    }

    // MARK: - Private

    private func screenSharingState(status: GliaCoreSDK.ScreenSharingStatus) -> CoreSdkClient.VisitorScreenSharingState {
        .init(status: status, localScreen: nil)
    }
}
