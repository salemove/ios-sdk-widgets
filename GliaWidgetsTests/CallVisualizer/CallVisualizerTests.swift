import XCTest
import Combine
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
            .mock(source: .callVisualizer)
        }
        let interactorMock = Interactor.mock()
        environmentMock.interactorPublisher = Just(interactorMock).eraseToAnyPublisher()
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

        let interactorMock = Interactor.mock()
        environmentMock.interactorPublisher = Just(interactorMock).eraseToAnyPublisher()
        interactorMock.onVisitorScreenSharingStateChange(
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
        environmentMock.getCurrentEngagement = { .mock() }

        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        let interactorMock = Interactor.mock()
        environmentMock.interactorPublisher = Just(interactorMock).eraseToAnyPublisher()
        interactorMock.onVisitorScreenSharingStateChange(
            screenSharingState(status: .sharing),
            nil
        )

        XCTAssertEqual(calls, [])
    }

    func test_coordinatorUpdatesWhenInteractorChanges() {
        let interactorSubject = CurrentValueSubject<Interactor?, Never>(nil)

        var environmentMock = CallVisualizer.Environment.mock
        environmentMock.interactorPublisher = interactorSubject.eraseToAnyPublisher()

        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        let oldInteractor = Interactor.mock()
        interactorSubject.send(oldInteractor)
        let engagement: CoreSdkClient.Engagement = .mock()

        oldInteractor.setCurrentEngagement(engagement)
        XCTAssertEqual(callVisualizer.coordinator.activeInteractor?.currentEngagement, engagement)

        let newInteractor = Interactor.mock()
        interactorSubject.send(newInteractor)
        XCTAssertEqual(callVisualizer.coordinator.activeInteractor?.currentEngagement, .none)
    }

    func test_CallVisualizerUpdatesWhenInteractorChanges() {
        let interactorSubject = CurrentValueSubject<Interactor?, Never>(nil)

        var environmentMock = CallVisualizer.Environment.mock
        environmentMock.interactorPublisher = interactorSubject.eraseToAnyPublisher()

        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        let oldInteractor = Interactor.mock()
        interactorSubject.send(oldInteractor)

        let engagement: CoreSdkClient.Engagement = .mock()
        oldInteractor.setCurrentEngagement(engagement)
        XCTAssertEqual(callVisualizer.activeInteractor?.currentEngagement, engagement)

        let newInteractor = Interactor.mock()
        interactorSubject.send(newInteractor)
        XCTAssertEqual(callVisualizer.activeInteractor?.currentEngagement, .none)
    }

    // MARK: - Private

    private func screenSharingState(status: GliaCoreSDK.ScreenSharingStatus) -> CoreSdkClient.VisitorScreenSharingState {
        .init(status: status, localScreen: nil)
    }
}
