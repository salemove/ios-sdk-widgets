import XCTest
import Combine
@testable import GliaWidgets

final class CallVisualizerTests: XCTestCase {
    private enum Call { case updateState }
    private var calls: [Call] = []

    override func setUp() {
        super.setUp()
        calls.removeAll()
    }

    func testHandlingInteractorEventWhenEngagementIsNil() {
        var environmentMock = CallVisualizer.Environment.mock
        environmentMock.getCurrentEngagement = { nil }

        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        let interactorMock = Interactor.mock()
        environmentMock.interactorPublisher = Just(interactorMock).eraseToAnyPublisher()

        XCTAssertEqual(calls, [])
    }

    func testHandlingInteractorEventWhenEngagementIsLive() {
        enum Call { case updateState }
        let calls: [Call] = []
        var environmentMock = CallVisualizer.Environment.mock
        environmentMock.getCurrentEngagement = { .mock() }

        let callVisualizer = CallVisualizer(environment: environmentMock)
        callVisualizer.startObservingInteractorEvents()

        let interactorMock = Interactor.mock()
        environmentMock.interactorPublisher = Just(interactorMock).eraseToAnyPublisher()

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
}
